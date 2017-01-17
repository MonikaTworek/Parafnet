class SQLRow {
    String tableName;
    Object[] values;
    String[] columnNames;
    int columnCount;

    SQLRow(String tableName, Object[] values, String[] columnNames) {
        this.tableName = tableName;
        this.values = values;
        this.columnNames = columnNames;
        this.columnCount = columnNames.length;


        System.out.println("ColumnCount of " + tableName + ": " + columnNames.length);
    }
}
