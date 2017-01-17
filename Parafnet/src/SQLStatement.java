import javax.swing.*;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

class SQLStatement {
    private static Connection con;
    private static Statement stmt;

    static void deleteRows(SQLRow[] rowData, int selectedRows) {
        try {
            con = ConnectionWithServer.getConnection();
            stmt = con.createStatement();

            for(int i = 0; i < selectedRows; i++) {
                String sql = "DELETE FROM " + rowData[i].tableName + " WHERE ";
                for (int j = 0; j < rowData[i].columnCount; j++) {
                    sql += rowData[i].columnNames[j] + " = \'" + rowData[i].values[j] + "\'";
                    if (j != rowData[i].columnCount - 1)
                        sql += " AND ";
                }
                stmt.executeUpdate(sql);
            }
        }
        catch(SQLException ex) {
            JOptionPane.showMessageDialog(null,"Błąd");
        }
    }

    static void modifyRows(SQLRow[] oldData, String[] newData) {
        try {
            con = ConnectionWithServer.getConnection();
            stmt = con.createStatement();
            String sql = "UPDATE " + oldData[0].tableName;
            String s = " SET ";
            String w = " WHERE ";
            int sCount = 0;
            int wCount = 0;

            for(int i = 0; i < oldData[0].columnCount; i++) {
                if (!newData[i].toString().equals(oldData[0].values[i].toString())) {
                    if(sCount != 0)
                        s += ", ";
                    s += oldData[0].columnNames[i] + " = \'" + newData[i] + "\'";
                    sCount++;
                }
                if(wCount != 0)
                    w += " AND ";
                w += oldData[0].columnNames[i] + " = " + "\'" + oldData[0].values[i] + "\'";
                wCount++;
            }
            stmt.executeUpdate(sql + s + w);
        }
        catch(SQLException ex) {
            JOptionPane.showMessageDialog(null,"Błąd");
        }
    }

    static void addNewRow(SQLRow rowData) {
        try {
            con = ConnectionWithServer.getConnection();
            stmt = con.createStatement();
            String sql = "INSERT INTO " + rowData.tableName;
            String c = "(";
            String d = " VALUES (";
            Object temp;
            int addedData = 0;

            for (int i = 0; i < rowData.columnCount; i++) {
                temp = rowData.values[i];
                if (!temp.equals("")) {
                    if (addedData != 0) {
                        d += ", ";
                        c += ", ";
                    }
                    c += rowData.columnNames[i];
                    d += "\'" + rowData.values[i] + "\'";
                    addedData++;
                }
            }
            c += ")";
            d += ")";
            stmt.executeUpdate(sql + c + d);
        }
        catch(SQLException ex) {
            JOptionPane.showMessageDialog(null,"Błąd");
        }
    }
}
