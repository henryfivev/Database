#include <windows.h>
#include <stdio.h>
#include <sql.h>
#include <sqlext.h>
int copyTableByODBC(char *src_dsn,char *src_user_id,char *src_user_password,
			char *target_dsn,char *target_user_id,char *target_user_password);

int main() {
	copyTableByODBC("university_in_mysql80","root","dsbdsb","university_in_sqlserver","sa","dsbdsb");
	copyTableByODBC("university_in_sqlserver","sa","dsbdsb","university_in_mysql80","root","dsbdsb");
    return 0;
}

int copyTableByODBC(char *src_dsn,char *src_user_id,char *src_user_password,
					char *target_dsn,char *target_user_id,char *target_user_password)
{
    SQLRETURN ret; //调用结果
	/*Step 1：定义句柄和变量*/
    SQLHENV src_env;  //环境句柄
    SQLHENV target_env;
    SQLHDBC src_dbc;  //连接句柄 
    SQLHDBC target_dbc;
    SQLHSTMT src_stmt; //语句句柄 
    SQLHSTMT target_stmt; 

	/*Step 2：初始化环境*/
    SQLAllocEnv(&src_env);
    SQLAllocEnv(&target_env);
    //设置管理环境的属性
	SQLSetEnvAttr(src_env, SQL_ATTR_ODBC_VERSION, (void *) SQL_OV_ODBC3, 0);
	SQLSetEnvAttr(target_env, SQL_ATTR_ODBC_VERSION, (void *) SQL_OV_ODBC3, 0);
   
	/*Step 3：建立连接*/
    //分配连接句柄
	ret = SQLAllocConnect(src_env, &src_dbc);
	ret = SQLAllocConnect(target_env, &target_dbc);

    ret = SQLConnect(src_dbc, (SQLCHAR *)src_dsn, SQL_NTS, (SQLCHAR *)src_user_id, SQL_NTS, (SQLCHAR *)src_user_password, SQL_NTS);
	if(!SQL_SUCCEEDED(ret)) //连接失败时返回错误值
		return -1;
    ret = SQLConnect(target_dbc, (SQLCHAR *)target_dsn, SQL_NTS, (SQLCHAR *)target_user_id, SQL_NTS, (SQLCHAR *)target_user_password, SQL_NTS);
	if(!SQL_SUCCEEDED(ret)) //连接失败时返回错误值
		return -1;
	
	/*Step 4：初始化语句句柄*/
    ret = SQLAllocStmt(src_dbc, &src_stmt);
    ret = SQLAllocStmt(target_dbc, &target_stmt);

    /*Step 5：两种方式执行语句*/
    /*执行SQL语句*/
	/*作为例子：创建目标表 T71_instructor*/ 
	ret = SQLExecDirect(target_stmt, (SQLCHAR *) "create table T71_instructor	(ID	varchar(5), name varchar(20) not null, dept_name varchar(20),  salary	numeric(8,2) )", SQL_NTS);
	SQLCHAR inst_id[6] = {0};
    SQLCHAR inst_name[41] = {0};
    SQLCHAR dept_name[21] = {0};
    SQLREAL inst_salary;
    
    /*方式一：预编译带有参数的语句*/
	//需要多次执行插入，因此预先声明插人语句
    SQLLEN lenIn1 = SQL_NTS,lenIn2 = SQL_NTS,lenIn3 = SQL_NTS,lenIn4=0;
	ret=SQLPrepare(target_stmt, (SQLCHAR *)"INSERT INTO T71_instructor(ID,name,dept_name, salary) VALUES(?, ?, ?, ?)",SQL_NTS);
	if(ret==SQL_SUCCESS)
	{
    	//绑定参数
		ret=SQLBindParameter(target_stmt, 1,SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 
							5,0,inst_id, sizeof(inst_id), &lenIn1);
    	ret=SQLBindParameter(target_stmt, 2,SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 
							20,0,inst_name, sizeof(inst_name), &lenIn2);
    	ret=SQLBindParameter(target_stmt, 3,SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 
							20,0,dept_name, sizeof(dept_name), &lenIn3);
    	ret=SQLBindParameter(target_stmt, 4,SQL_PARAM_INPUT, SQL_C_FLOAT, SQL_FLOAT,
							8,2, &inst_salary, 0, &lenIn4);
	}

    SQLLEN lenOut1,lenOut2,lenOut3,lenOut4;
    unsigned char query[] = "select id,name,dept_name,salary from instructor";
    /*执行SQL语句*/
	ret = SQLExecDirect(src_stmt, (SQLCHAR *) query, SQL_NTS);
	if (ret == SQL_SUCCESS){ 
		//将结果集中的属性列一一绑定至变量
    	SQLBindCol(src_stmt, 1, SQL_C_CHAR, inst_id, sizeof(inst_id), &lenOut1);
    	SQLBindCol(src_stmt, 2, SQL_C_CHAR, inst_name, sizeof(inst_name), &lenOut2);
    	SQLBindCol(src_stmt, 3, SQL_C_CHAR, dept_name, sizeof(dept_name), &lenOut3);
    	SQLBindCol(src_stmt, 4, SQL_C_FLOAT,&inst_salary, 0, &lenOut4);
	    /*Step 6：处理结果集并执行预编译后的语句*/
		while ((ret=SQLFetch(src_stmt))==SQL_SUCCESS) {
    	    printf("%s\t %s\t %s\t %g\n", inst_id,inst_name,dept_name,inst_salary);
			ret=SQLExecute(target_stmt);
    	}
   	}
    else
  	    printf("%d\n", ret);
/*Step 7：中止处理*/
  	SQLFreeStmt(src_stmt,SQL_DROP);
	SQLDisconnect(src_dbc);				    
	SQLFreeConnect(src_dbc);				    
	SQLFreeEnv(src_env);
	
  	SQLFreeStmt(target_stmt,SQL_DROP);
	SQLDisconnect(target_dbc);				    
	SQLFreeConnect(target_dbc);				    
	SQLFreeEnv(target_env);
}
