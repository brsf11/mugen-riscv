import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
public class Test {
    public static void main(String[] args) throws Exception {
        Connection conn = null;
        ResultSet rs = null;
        Statement stat = null;
        try {
            Class.forName("org.sqlite.JDBC");
            conn = DriverManager.getConnection("jdbc:sqlite:test.db");
            System.out.println("The connection object con is: "+conn);
            stat = conn.createStatement();
            rs = stat.executeQuery("select * from t_user;");
            while (rs.next()) {
                System.out.print("t_user_name = " + rs.getString("name")+ " ");
                System.out.println("t_user_age = " + rs.getInt("age"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) {
                try {
                    rs.close();
                } finally {
                    if (stat != null) {
                        try {
                            stat.close();
                        } finally {
                            if (conn != null) {
                                conn.close();
                            }
                        }
                    }
                }
            }
        }
    }
}
