import org.oxbow.swingbits.table.filter.TableRowFilterSupport;

import javax.swing.*;
import javax.swing.border.TitledBorder;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.sql.*;
import java.util.Vector;

class Agenda extends JLayeredPane {
    private JPanel panel1;
    private JPanel panel2;
    private JButton button1;
    private JComboBox<String> priestsList;
    private JLabel label1;
    JTable table;
//    private JTextArea area;

    Agenda() {
        initComponents();
        panel1.setBorder(BorderFactory.createTitledBorder(null, "Terminarz", TitledBorder.DEFAULT_JUSTIFICATION,
                TitledBorder.DEFAULT_POSITION, new Font("Dialog", 0, 11)));

        panel2.setBorder(BorderFactory.createTitledBorder(null, "Operacje", TitledBorder.DEFAULT_JUSTIFICATION,
                TitledBorder.DEFAULT_POSITION, new Font("Dialog", 0, 11)));

        panel1.setBounds(10, 10, 850, 450);
        panel2.setBounds(10, 470, 850, 130);

        label1.setBounds(100, 20, 45, 30);
        priestsList.setBounds(175, 27, 200, 20);

        button1.setBounds(350, 80, 150, 30);

        add(panel1);
        add(panel2);
        panel2.add(button1);
        panel2.add(priestsList);
        panel2.add(label1);

        setComboBoxes();
        addListeners();
    }

    private void initComponents() {
        panel1 = new JPanel();
        panel2 = new JPanel(null);
        button1 = new JButton("Wygeneruj");
        priestsList = new JComboBox<>();
        label1 = new JLabel("Ksiądz:");
//        area = new JTextArea();
    }

    private void addListeners() {
        button1.addActionListener(e -> {
            if(priestsList.getSelectedItem() != null) {
                String priest = priestsList.getSelectedItem().toString();
                int priestNumber = Integer.parseInt(priest);
                System.out.println(priestNumber);

                    table = new JTable(new DefaultTableModel(new Object[]{"Data", "Zajęcie"}, 0));
                    TableRowFilterSupport.forTable(table).searchable(true).apply();

                    table.getTableHeader().setReorderingAllowed(false);
                    table.setPreferredScrollableViewportSize(new Dimension(810, 250));

                    DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
                    centerRenderer.setHorizontalAlignment(JLabel.CENTER);
                    table.setDefaultRenderer(String.class, centerRenderer);
                    JScrollPane scrollPane = new JScrollPane(table);
                    table.setEnabled(false);
                    panel1.add(scrollPane);

                Connection conn = ConnectionWithServer.getConnection();
                try {
                    PreparedStatement stmt = conn.prepareStatement("SELECT * FROM Terminarz(?)");
                    stmt.setInt(1, priestNumber);
                    ResultSet rs = stmt.executeQuery();
                    while(rs.next()) {
                        String date = rs.getString(1);
                        String what = rs.getString(2);

                        if(table != null) {
                            DefaultTableModel model = (DefaultTableModel) table.getModel();
                            System.out.println(date + ", " + what);
                            model.addRow(new Object[]{date, what});
                        }

                    }
                } catch (SQLException se) {
                    JOptionPane.showMessageDialog(null,"Błąd");
                }
            }
        });
    }

    private void setComboBoxes() {
        Vector<String> data1 = new Vector<>();
        Vector<String> data2 = new Vector<>();
        try {
            String sql1 = "SELECT * FROM Ksiadz";
            Statement stmt = ConnectionWithServer.getConnection().createStatement();
            ResultSet rs1 = stmt.executeQuery(sql1);
            while (rs1.next()) {
                data1.add(rs1.getString("IDKsiedza"));
            }

            ResultSet rs2 = stmt.executeQuery(sql1);
            while (rs2.next()) {
                data2.add(rs2.getString("DataPrzybycia"));
            }
        }
        catch(SQLException e) {
            JOptionPane.showMessageDialog(null,"Błąd");
        }
        priestsList.setModel(new DefaultComboBoxModel<>(data1));
        priestsList.setSelectedIndex(-1);
//        datesList.setModel(new DefaultComboBoxModel<>(data2));
//        datesList.setSelectedIndex(-1);
    }

    private void createTable() {
    }
}
