import javax.swing.*;
import java.sql.*;
import java.util.Vector;

public class ConnectionWithServer {
    static private Connection connection;

    private static boolean connectWithDatabase(String username, String password) throws ConnectionFailedException {
        try {
            String conURL = "jdbc:sqlserver://localhost:1433;databaseName=parafnet;integratedSecurity=true";

            System.out.println(username + password);
            connection = DriverManager.getConnection(conURL, username, password);
            if (connection != null) {
                DatabaseMetaData dm = connection.getMetaData();
                System.out.println("Driver name: " + dm.getDriverName());
                System.out.println("Driver version: " + dm.getDriverVersion());
                System.out.println("Product name: " + dm.getDatabaseProductName());
                System.out.println("Product version: " + dm.getDatabaseProductVersion());
                return true;
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(null,"Błąd");
            throw new ConnectionFailedException();
        }
        return false;
    }

    static boolean logIn(String username, String password) throws ConnectionFailedException {
        try {
            return ConnectionWithServer.connectWithDatabase(username, password);
        }
        catch(ConnectionFailedException ex) {
            throw new ConnectionFailedException();
        }
    }

    static void logOut() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(null,"Błąd");
        }
    }

    static Connection getConnection() {
        return connection;
    }

    static Vector<String> getColumnNames() {
        Vector<String> list = new Vector<>();
        DatabaseMetaData md;
        try {
            md = ConnectionWithServer.getConnection().getMetaData();
            ResultSet rs = md.getTables(null, null, "%", null);
            while (rs.next()) {
                if (rs.getString(4).equals("TABLE") && rs.getString("TABLE_SCHEM").equals("dbo")) {
                    if(!rs.getString(3).equals("kasa") && !rs.getString(3).equals("Koleda")) {
                        String row = rs.getString(3);
                        list.add(row);
                    }
                }
            }
        }
        catch(SQLException e) {
            JOptionPane.showMessageDialog(null,"Błąd");
        }
        return list;
    }

    static Vector<String> fkMethod(String tableName, String columnName) {
        Vector<String> result = new Vector<>();

        String[] pkInfo = getPKInfo(tableName, columnName);
        if(pkInfo != null) {
            try {
                String sql = "SELECT " + pkInfo[1] + " FROM " + pkInfo[0];
                Statement stmt = connection.createStatement();

                ResultSet rs = stmt.executeQuery(sql);
                while (rs.next()) {
                    result.add(rs.getString(pkInfo[1]));
                }
            }
            catch(SQLException e) {
                JOptionPane.showMessageDialog(null,"Błąd");
            }
            return result;
        }
        else
            return null;
    }

    static private String[] getPKInfo(String table, String column) {
        try {
            DatabaseMetaData metaData = connection.getMetaData();
            ResultSet foreignKeys = metaData.getImportedKeys(connection.getCatalog(), null, table);
            while (foreignKeys.next()) {
                String fkTableName = foreignKeys.getString("FKTABLE_NAME");
                String fkColumnName = foreignKeys.getString("FKCOLUMN_NAME");
                if(table.equals(fkTableName) && column.equals(fkColumnName))
                    return new String[]{foreignKeys.getString("PKTABLE_NAME"), foreignKeys.getString("PKCOLUMN_NAME")};
            }
        }
        catch(SQLException e) {
            JOptionPane.showMessageDialog(null,"Błąd");
        }
        return null;
    }
}