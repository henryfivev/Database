#include <windows.h>
#include <stdio.h>
#include <sql.h>
#include <sqlext.h>
int showTableByODBC(char *dsn,char *user_id,char *user_password);

int main() {
	showTableByODBC("university_in_mysql80","root","dsbdsb");
	showTableByODBC("university_in_sqlserver","sa","dsbdsb");
    return 0;
}

int showTableByODBC(char *dsn,char *user_id,char *user_password)
{
	/*Step 1：定义句柄和变量*/
    SQLHENV env;  //环境句柄
    SQLHDBC dbc;  //连接句柄 
    SQLRETURN ret; //调用结果
    SQLHSTMT stmt; //语句句柄 

	/*Step 2：初始化环境*/
    //SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &env);
    SQLAllocEnv(&env);
    //设置管理环境的属性
	SQLSetEnvAttr(env, SQL_ATTR_ODBC_VERSION, (void *) SQL_OV_ODBC3, 0);
   
	/*Step 3：建立连接*/
    //分配连接句柄
	//SQLAllocHandle(SQL_HANDLE_DBC, env, &dbc);
	ret = SQLAllocConnect(env, &dbc);

    SQLCHAR *server = (SQLCHAR *)dsn;
    SQLCHAR *user = (SQLCHAR *)user_id;
    SQLCHAR *password = (SQLCHAR *)user_password;    
    ret = SQLConnect(dbc, server, SQL_NTS, user, SQL_NTS, password, SQL_NTS);
	if(!SQL_SUCCEEDED(ret)) //连接失败时返回错误值
		return -1;
	
	/*Step 4：初始化语句句柄*/
    //SQLAllocHandle(SQL_HANDLE_STMT, dbc, &stmt);
    ret = SQLAllocStmt(dbc, &stmt);

    /*Step 5：两种方式执行语句*/
	SQLCHAR inst_id[6] = {0};
    SQLCHAR inst_name[41] = {0};
    SQLCHAR dept_name[21] = {0};
    SQLREAL 	inst_salary;
    
    SQLLEN lenOut1,lenOut2,lenOut3,lenOut4;
//    unsigned char query[] = "select dept_name,sum(salary) from instructor group by dept_name";
    unsigned char query[] = "select id,name,dept_name,salary from instructor";
    /*执行SQL语句*/
	ret = SQLExecDirect(stmt, (SQLCHAR *) query, SQL_NTS);
	if (ret == SQL_SUCCESS){ 
		//将结果集中的属性列一一绑定至变量
    	SQLBindCol(stmt, 1, SQL_C_CHAR, inst_id, sizeof(inst_id), &lenOut1);
    	SQLBindCol(stmt, 2, SQL_C_CHAR, inst_name, sizeof(inst_name), &lenOut2);
    	SQLBindCol(stmt, 3, SQL_C_CHAR, dept_name, sizeof(dept_name), &lenOut3);
    	SQLBindCol(stmt, 4, SQL_C_FLOAT,&inst_salary, 0, &lenOut4);
	    /*Step 6：处理结果集并执行预编译后的语句*/
		while ((ret=SQLFetch(stmt))==SQL_SUCCESS) {
    	    printf("%s\t %s\t %s\t %g\n", inst_id,inst_name,dept_name,inst_salary);
    	}
   	}
    else
  	    printf("%d\n", ret);
/*Step 7：中止处理*/
  	SQLFreeStmt(stmt,SQL_DROP);
	SQLDisconnect(dbc);				    
	SQLFreeConnect(dbc);				    
	SQLFreeEnv(env);
}
