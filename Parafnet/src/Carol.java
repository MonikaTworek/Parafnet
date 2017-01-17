import org.oxbow.swingbits.table.filter.TableRowFilterSupport;

import javax.swing.*;
import javax.swing.border.TitledBorder;
import javax.swing.table.DefaultTableCellRenderer;
import java.awt.*;
import java.sql.SQLException;

public class Carol extends JLayeredPane {
    private MyTable table;
    private TableModel model;
    private JPanel panel1;
    private JPanel panel2;
    private JButton button;
    private String sqlQuery;

    Carol() {
        initComponents();
        panel1.setBorder(BorderFactory.createTitledBorder(null, "Baza", TitledBorder.DEFAULT_JUSTIFICATION,
                TitledBorder.DEFAULT_POSITION, new Font("Dialog", 0, 11)));
        panel2.setBorder(BorderFactory.createTitledBorder(null, "Opcje", TitledBorder.DEFAULT_JUSTIFICATION,
                TitledBorder.DEFAULT_POSITION, new Font("Dialog", 0, 11)));

        panel1.setBounds(10, 10, 850, 500);
        panel2.setBounds(10, 510, 850, 90);

        button.setBounds(70, 50, 100, 20);

        add(panel1);
        add(panel2);
        panel2.add(button);

        addListeners();
    }

    private void initComponents() {
        panel1 = new JPanel();
        panel2 = new JPanel(null);
        button = new JButton("Generuj");
    }

    private void addListeners() {
        sqlQuery = "SELECT IDRodziny, AdresZamieszkania as Adres FROM Rodzina WHERE CzyPrzyjmujeKolede = \'true\'";

        button.addActionListener(e -> {
            try {
                if (table != null) {
                    refreshComponents();
                } else {
                    table = new MyTable();
                    TableRowFilterSupport.forTable(table).searchable(true).apply();
                    model = new TableModel(sqlQuery);
                    table.setModel(model);

                    table.getTableHeader().setReorderingAllowed(false);
                    table.setPreferredScrollableViewportSize(new Dimension(810, 500));

                    DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
                    centerRenderer.setHorizontalAlignment(JLabel.CENTER);
                    table.setDefaultRenderer(String.class, centerRenderer);
                    JScrollPane scrollPane = new JScrollPane(table);
                    panel1.add(scrollPane);
                }
            } catch (SQLException e1) {
                JOptionPane.showMessageDialog(null,"Błąd");
            }
        });
    }


    private void refreshComponents() {
        try {
            model = new TableModel(sqlQuery);
            table.setModel(model);
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
}
