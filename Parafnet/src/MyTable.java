import javax.swing.*;

class MyTable extends JTable {
    MyTable() {
        super();
    }

    SQLRow[] getClickedRows(String tableName) {
        int[] selected = getSelectedRows();
        int count = getSelectedRowCount();
        SQLRow[] result = new SQLRow[count];
        int columnCount = getColumnCount();
        String[] columnNames = new String[columnCount];
        for(int i = 0; i < columnCount; i++)
            columnNames[i] = getColumnName(i);

        for (int i = 0; i < count; i++) {
            Object[] values = new Object[columnCount];
            for (int j = 0; j < columnCount; j++) {
                values[j] = getValueAt(selected[i], j);
            }
            result[i] = new SQLRow(tableName, values, columnNames);
        }
        return result;
    }

    String[] getTableColumnNames() {
        String[] columns = new String[getColumnCount()];
        for(int i = 0; i < getColumnCount(); i++)
            columns[i] = getColumnName(i);
        return columns;
    }
}
