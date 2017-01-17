import javax.swing.*;
import javax.swing.table.AbstractTableModel;
import java.sql.*;

class TableModel extends AbstractTableModel {
    private ResultSet resultSet;
    private ResultSetMetaData metaData;
    private int numberOfRows;

    TableModel(String query) throws SQLException {
        Connection connection = ConnectionWithServer.getConnection();
        Statement statement = connection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        resultSet = statement.executeQuery(query);
        metaData = resultSet.getMetaData();
        resultSet.last();
        numberOfRows = resultSet.getRow();
        fireTableStructureChanged();
    }

    public int getColumnCount() {
        try {
            return metaData.getColumnCount();
        } catch (SQLException sex) {
            System.out.println(sex.getMessage());
            JOptionPane.showMessageDialog(null,"Błąd");
        }

        return 0;
    }

    public int getRowCount() {
        return numberOfRows;
    }

    public String getColumnName(int col) {
        try {
            return metaData.getColumnName(col + 1);
        } catch (SQLException sex) {
            System.out.println(sex.getMessage());
            JOptionPane.showMessageDialog(null,"Błąd");
        }

        return "";
    }

    public Object getValueAt(int row, int col) {
        try {
            resultSet.absolute(row + 1);
            return resultSet.getObject(col + 1);
        } catch (SQLException sex) {
            System.out.println(sex.getMessage());
            JOptionPane.showMessageDialog(null,"Błąd");
        }
        return "";
    }

    public Class getColumnClass(int c) {
        try {
            String className = metaData.getColumnClassName(c + 1);
            return Class.forName(className);
        } catch (Exception ex) {
            System.out.println(ex.getMessage());
        }
        return Object.class;
    }

    String[] getColumnNames() {
        String[] colNames = new String[10];
        for(int i = 0; i < getColumnCount(); i++) {
            try {
                colNames[i] = metaData.getColumnName(i + 1);
            } catch (SQLException e) {
                JOptionPane.showMessageDialog(null,"Błąd");
            }
        }
        return colNames;
    }
}
