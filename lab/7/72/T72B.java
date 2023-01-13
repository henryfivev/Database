import java.sql.*;
public class T72B {
    public static void main(String[] args) {
        showTableByJDBC("com.mysql.cj.jdbc.Driver"  
                        ,"jdbc:mysql://localhost:3306/university?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
                        ,"root","dsbdsb");

        showTableByJDBC("com.microsoft.sqlserver.jdbc.SQLServerDriver"  
                        ,"jdbc:sqlserver://localhost:1433;DatabaseName=university;"
                            + "encrypt=true;"
                            + "trustServerCertificate=true;"
                            + "loginTimeout=30;"
                        ,"sa","dsbdsb");
    }  
    public static void showTableByJDBC(String JDBC_DRIVER,String DB_URL,String USER,String PASS) {
        Connection conn = null;
        Statement stmt = null;
        try{
            // step 1 加载驱动程序：Class.forName(driverName);
            Class.forName(JDBC_DRIVER);
            // step 2 获得数据库连接 ：Connection con = DriverManager.getConnection(dbURL, userName, userPwd);
            System.out.println("连接数据库..."+DB_URL);
            conn = DriverManager.getConnection(DB_URL,USER,PASS);
            ResultSet rs;
        
            // step 3 创建Statement/PreparedStatement对象，用来执行sql语句
            // step 3.1 创建Statement： Statement stmt = con.createStatement();
            // step 3.2 创建PreparedStatement对象
            stmt = conn.createStatement();
            
            //step 4 给占位符赋值
            //step 5 执行sql语句(接收结果集)：ResultSet rs = stmt.executeQuery(sqlStr);
            String sql;
            sql = "select id,name,dept_name,salary from instructor";
            rs = stmt.executeQuery(sql);
            // step 6 处理结果:遍历结果集
            System.out.print("id\tname\tdept_name\tsalary\n");
            while(rs.next()){
                // 通过字段检索
                String inst_id = rs.getString("id");
                String inst_name = rs.getString("name");
                String dept_name = rs.getString("dept_name");
                Float salary = rs.getFloat("salary");
               // 输出数据
                System.out.print(inst_id);
                System.out.print("\t" + inst_name);
                System.out.print("\t" + dept_name);
                System.out.print("\t" + salary);
                System.out.print("\n");
            }
            // step 7 完成后关闭各个对象
            rs.close();
            stmt.close();
            conn.close();
        }catch(SQLException se){
            // 处理 JDBC 错误
            se.printStackTrace();
        }catch(Exception e){
            // 处理 Class.forName 错误
            e.printStackTrace();
        }finally{
            // 关闭资源
            try{
                if(stmt!=null) stmt.close();
            }catch(SQLException se2){
            }// 什么都不做
            try{
                if(conn!=null) conn.close();
            }catch(SQLException se){
                se.printStackTrace();
            }
        }
        System.out.println("Goodbye!");
    }
   
}
