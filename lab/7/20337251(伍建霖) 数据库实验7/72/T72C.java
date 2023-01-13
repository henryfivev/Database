import java.sql.*;
public class T72C {
    public static void main(String[] args) {
        copyTableByJDBC("com.mysql.cj.jdbc.Driver"  
                        ,"jdbc:mysql://localhost:3306/university?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
                        ,"root","dsbdsb",
                       "com.microsoft.sqlserver.jdbc.SQLServerDriver"  
                    ,"jdbc:sqlserver://localhost:1433;DatabaseName=university;"
                            + "encrypt=true;"
                            + "trustServerCertificate=true;"
                            + "loginTimeout=30;"
                        ,"sa","dsbdsb");
        copyTableByJDBC("com.microsoft.sqlserver.jdbc.SQLServerDriver"  
                    ,"jdbc:sqlserver://localhost:1433;DatabaseName=university;"
                            + "encrypt=true;"
                            + "trustServerCertificate=true;"
                            + "loginTimeout=30;"
                        ,"sa","dsbdsb"
                        ,"com.mysql.cj.jdbc.Driver"  
                        ,"jdbc:mysql://localhost:3306/university?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
                        ,"root","dsbdsb"
                        );
    }
    
    public static void copyTableByJDBC(String src_JDBC_DRIVER,String src_DB_URL,String src_USER,String src_PASS,
     String target_JDBC_DRIVER,String target_DB_URL,String target_USER,String target_PASS )
    {
        Connection src_conn = null;
        Statement src_stmt = null;
        Connection target_conn = null;
        PreparedStatement target_ps=null;
        try{
            System.out.println("连接数据库..."+src_DB_URL);
            System.out.println("连接数据库..."+target_DB_URL);
            // step 1 加载驱动程序：Class.forName(driverName);
            Class.forName(src_JDBC_DRIVER);
            Class.forName(target_JDBC_DRIVER);
            // step 2 连接数据库 ：Connection con = DriverManager.getConnection(dbURL, userName, userPwd);
            src_conn = DriverManager.getConnection(src_DB_URL,src_USER,src_PASS);
            target_conn = DriverManager.getConnection(target_DB_URL,target_USER,target_PASS);
            ResultSet src_rs;
            // step 3 创建Statement/PreparedStatement对象，用来执行sql语句
            // step 3.1 创建Statement： Statement stmt = con.createStatement();
            // step 3.2 创建PreparedStatement对象: PreparedStatement ps=prepareStatement(sql);
            src_stmt = src_conn.createStatement();
            target_ps = target_conn.prepareStatement("create table T72_instructor	(ID	varchar(5), name varchar(20) not null, dept_name varchar(20),  salary	numeric(8,2) )");
            target_ps.executeUpdate();
            
            target_ps = target_conn.prepareStatement("INSERT INTO T72_instructor(ID,name,dept_name, salary) VALUES(?, ?, ?, ?)");

            //step 5 执行sql语句(接收结果集)：ResultSet rs = stmt.executeQuery(sqlStr);
            String select_sql;
            select_sql = "select id,name,dept_name,salary from instructor";
            src_rs = src_stmt.executeQuery(select_sql);
            // step 6 处理结果:遍历结果集
            System.out.print("id\tname\tdept_name\tsalary\n");
            while(src_rs.next()){
                // 通过字段检索
                String inst_id = src_rs.getString("id");
                String inst_name = src_rs.getString("name");
                String dept_name = src_rs.getString("dept_name");
                Float salary = src_rs.getFloat("salary");
               // 输出数据
                System.out.print(inst_id);
                System.out.print("\t" + inst_name);
                System.out.print("\t" + dept_name);
                System.out.print("\t" + salary);
                System.out.print("\n");
                
            //step 4 给占位符赋值
                target_ps.setString(1, inst_id);  //给第1个占位符赋值(ID)
                target_ps.setString(2, inst_name);//给第2个占位符赋值(name)
                target_ps.setString(3, dept_name);//给第3个占位符赋值(dept_name)
                target_ps.setFloat(4, salary);   //给第4个占位符赋值(salary)
            //step 5.2 执行sql语句(更新操作)：ps.executeUpdate();
                target_ps.executeUpdate();
            }

            // step 7 完成后关闭各个对象
            src_rs.close();
            src_stmt.close();
            src_conn.close();
            
            target_ps.close();
            target_conn.close();
        }catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }catch(Exception e){
            e.printStackTrace();
        }
        System.out.println("Goodbye!");
    }
    
}
