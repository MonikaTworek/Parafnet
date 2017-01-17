import org.oxbow.swingbits.table.filter.TableRowFilterSupport;

import javax.swing.*;
import javax.swing.border.TitledBorder;
import javax.swing.table.DefaultTableCellRenderer;
import java.awt.*;
import java.sql.SQLException;
import java.util.Vector;

class BrowseDatabase extends JLayeredPane {
    private MyTable table;
    private TableModel model;
    private JComboBox<String> labList;
    private JLabel label;
    private JLabel[] labels;
    private JTextField[] fields;
    private JComboBox[] fkList;
    private JPanel panel1;
    private JPanel panel2;
    private JButton button1;
    private JButton button2;
    private JButton button3;
    private JButton button4;
    private String sqlQuery;
    private String activeTable;

    BrowseDatabase() {
        initComponents();
        panel1.setBorder(BorderFactory.createTitledBorder(null, "Baza", TitledBorder.DEFAULT_JUSTIFICATION,
                TitledBorder.DEFAULT_POSITION, new Font("Dialog", 0, 11)));
        panel2.setBorder(BorderFactory.createTitledBorder(null, "Operacje", TitledBorder.DEFAULT_JUSTIFICATION,
                TitledBorder.DEFAULT_POSITION, new Font("Dialog", 0, 11)));

        panel1.setBounds(10, 10, 850, 300);
        panel2.setBounds(10, 320, 850, 280);
        add(panel2);
        add(panel1);

        setComponents();
        changeVisibility(false, 6);

        panel2.add(label);
        panel2.add(labList);
        for(int i = 0; i < 6; i++) {
            panel2.add(labels[i]);
            panel2.add(fields[i]);
            panel2.add(fkList[i]);
        }

        button1.setBounds(10, 247, 130, 20);
        button2.setBounds(150, 247, 130, 20);
        button3.setBounds(290, 247, 130, 20);
        button4.setBounds(430, 247, 130, 20);

        panel2.add(button1);
        panel2.add(button2);
        panel2.add(button3);
        panel2.add(button4);

        labList.addActionListener(e -> {
            activeTable = labList.getSelectedItem().toString();
            sqlQuery = "SELECT * FROM " + activeTable;

            try {
                if(table != null) {
                    refreshComponents();
                }
                else {
                    table = new MyTable();
                    TableRowFilterSupport.forTable(table).searchable(true).apply();
                    model = new TableModel(sqlQuery);
                    table.setModel(model);

                    setLabelNames();
                    table.getTableHeader().setReorderingAllowed(false);
                    table.setPreferredScrollableViewportSize(new Dimension(810, 250));

                    DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
                    centerRenderer.setHorizontalAlignment(JLabel.CENTER);
                    table.setDefaultRenderer(String.class, centerRenderer);
                    JScrollPane scrollPane = new JScrollPane(table);
                    panel1.add(scrollPane);

                    table.getSelectionModel().addListSelectionListener(event -> {
                        int row = table.getSelectedRow();
                        int column = table.getColumnCount();
                        clearFields();
                        if(row >= 0) {
                            Object[] fieldsValues = new Object[column];
                            for (int i = 0; i < column; i++)
                                fieldsValues[i] = table.getValueAt(row, i);
                            setFieldsValues(fieldsValues);
                        }
                    });
                }
                clearFields();
                setFKComboBoxes();
            } catch (SQLException e1) {
                JOptionPane.showMessageDialog(null,"Błąd");
            }
            catch (ArrayIndexOutOfBoundsException ignored) {}
        });
    }

    private void initComponents() {
        label = new JLabel("Tabela: ");
        labels = new JLabel[6];
        fields = new JTextField[6];
        fkList = new JComboBox[6];
        panel1 = new JPanel();
        panel2 = new JPanel(null);

        button1 = new JButton("Dodaj nowy");
        button2 = new JButton("Zmodyfikuj");
        button3 = new JButton("Usuń rekordy");
        button4 = new JButton("Wyczyść pola");

        addButtonListeners();

        for(int i = 0; i < 6; i++) {
            labels[i] = new JLabel();
            fields[i] = new JTextField();
            fkList[i] = new JComboBox<>();
            fkList[i].setSelectedIndex(-1);
            fkList[i].setRenderer(new ComboBoxRenderer(""));
            fkList[i].setVisible(false);
        }

        addComboBoxListeners();

        labList = new JComboBox<>(ConnectionWithServer.getColumnNames());
        labList.setSelectedIndex(-1);
        activeTable = "";
    }

    private void setComponents() {
        label.setBounds(10, 20, 50, 22);
        labList.setBounds(60, 21, 150, 22);

        labels[0].setBounds(10, 52, 150, 22);
        fields[0].setBounds(160, 53, 300, 22);
        fkList[0].setBounds(470, 53, 50, 22);

        labels[1].setBounds(10, 84, 150, 22);
        fields[1].setBounds(160, 85, 300, 22);
        fkList[1].setBounds(470, 85, 50, 22);

        labels[2].setBounds(10, 116, 150, 22);
        fields[2].setBounds(160, 117, 300, 22);
        fkList[2].setBounds(470, 117, 50, 22);

        labels[3].setBounds(10, 148, 150, 22);
        fields[3].setBounds(160, 149, 300, 22);
        fkList[3].setBounds(470, 149, 50, 22);

        labels[4].setBounds(10, 180, 150, 22);
        fields[4].setBounds(160, 181, 300, 22);
        fkList[4].setBounds(470, 181, 50, 22);

        labels[5].setBounds(10, 212, 150, 22);
        fields[5].setBounds(160, 213, 300, 22);
        fkList[5].setBounds(470, 213, 50, 22);
    }

    private void refreshComponents() {
        try {
            model = new TableModel(sqlQuery);
            table.setModel(model);
            setLabelNames();
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(null,"Błąd");
        }
    }

    private void setLabelNames() {
        changeVisibility(false, 6);
        int labelCount = model.getColumnCount();
        String[] labelNames = model.getColumnNames();
        changeVisibility(true, labelCount);
        for(int i = 0; i < labelCount; i++) {
            labels[i].setText(labelNames[i]);
        }
    }

    private String printSelectedRows() {
        SQLRow[] result = table.getClickedRows(activeTable);
        int clickedRowCount = table.getSelectedRowCount();
        int columns = table.getColumnCount();
        String s = "";

        for (int i = 0; i < clickedRowCount; i++) {
            for (int j = 0; j < columns; j++) {
                s += result[i].values[j];
                if(j != columns - 1)
                    s +=  ", ";
            }
            if(i != clickedRowCount - 1)
                s += "\n";
        }
        return s;
    }

    private void addButtonListeners() {
        button1.addActionListener(e -> {
            SQLRow row = new SQLRow(activeTable, getFieldsData(), table.getTableColumnNames());
            SQLStatement.addNewRow(row);
            refreshComponents();
        });

        button2.addActionListener(e -> {
            int selectedRows = table.getSelectedRowCount();
            if(selectedRows == 1) {
                String string = "Czy na pewno chcesz zmienić wiersz:\n" + printSelectedRows() + "\nz tabeli " + activeTable + " ?";
                int c = JOptionPane.showConfirmDialog(null, string, "Modyfikowanie",
                        JOptionPane.YES_NO_OPTION, JOptionPane.INFORMATION_MESSAGE);
                if (c == JOptionPane.OK_OPTION) {
                    System.out.println("Zgoda na modyfikację.");

                    SQLStatement.modifyRows(table.getClickedRows(activeTable), getFieldsData());
                    refreshComponents();
                }
                else
                    System.out.println("Brak zgody na wprowadzenie zmian.");
            }
            else
                JOptionPane.showMessageDialog(this, "Błąd: Należy wskazać jeden wiersz do modyfikacji.");
        });

        button3.addActionListener(e -> {
            int selectedRows = table.getSelectedRowCount();
            if(selectedRows >= 1) {
               String string = "Czy na pewno chcesz usunąć wiersze:\n" + printSelectedRows() + "\nz tabeli " + activeTable + " ?";
                int c = JOptionPane.showConfirmDialog(null, string, "Usuwanie",
                        JOptionPane.YES_NO_OPTION, JOptionPane.INFORMATION_MESSAGE);
                if (c == JOptionPane.OK_OPTION) {
                    System.out.println("Zgoda na usuniecie.");

                    SQLStatement.deleteRows(table.getClickedRows(activeTable), table.getSelectedRowCount());
                    refreshComponents();
                }
                else
                    System.out.println("Brak zgody na usunięcie.");
            }
            else if(selectedRows == 0)
                JOptionPane.showMessageDialog(this, "Błąd: Nie wskazano żadnych wierszy.");
        });

        button4.addActionListener(e -> clearFields());
    }

    private void addComboBoxListeners() {
        for(int i = 0; i < fkList.length; i++) {
            int finalI = i;
            fkList[i].addItemListener(e -> {
                int value = fkList[finalI].getSelectedIndex() + 1;
                if(value != -1 && value != 0)
                    fields[finalI].setText("" + value);
            });
        }
    }

    private String[] getFieldsData() {
        String[] data = new String[6];
        for(int i = 0; i < 6; i++)
            data[i] = fields[i].getText();
        return data;
    }

    private void clearFields() {
        for(int i = 0; i < 6; i++)
            fields[i].setText("");
    }

    private void setFieldsValues(Object[] fieldsValues) {
        clearFields();
        for(int i = 0; i < table.getColumnCount(); i++) {
            if(fieldsValues[i] != null) {
                String convertedField = fieldsValues[i].toString();
                fields[i].setText(convertedField);
            }
        }
    }

    private void changeVisibility(boolean state, int count) {
        if(!state)
            hideAllComboBoxes();
        for(int i = 0; i < count; i++) {
            labels[i].setVisible(state);
            fields[i].setVisible(state);

        }
        button1.setVisible(state);
        button2.setVisible(state);
        button3.setVisible(state);
        button4.setVisible(state);
    }

    private void setFKComboBoxes() {
        Vector<String> fkListData;
        for(int i = 0; i < table.getColumnCount(); i++) {
            fkListData = ConnectionWithServer.fkMethod(activeTable, table.getColumnName(i));
            if(fkListData != null) {
                fkList[i].setModel(new DefaultComboBoxModel<>(fkListData));
                fkList[i].setVisible(true);
                fkList[i].setSelectedIndex(-1);
            }
        }
    }

    private void hideAllComboBoxes() {
        for(JComboBox box : fkList)
            box.setVisible(false);
    }

    class ComboBoxRenderer extends JLabel implements ListCellRenderer {
        private String _title;

        ComboBoxRenderer(String title) {
            _title = title;
        }

        @Override
        public Component getListCellRendererComponent(JList list, Object value, int index, boolean isSelected, boolean hasFocus) {
            if (index == -1 && value == null)
                setText(_title);
            else
                setText(value.toString());
            return this;
        }
    }
}
