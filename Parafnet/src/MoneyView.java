import org.oxbow.swingbits.table.filter.TableRowFilterSupport;

import javax.swing.*;
import javax.swing.border.TitledBorder;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

class MoneyView extends JLayeredPane {
    private MyTable table;
    private TableModel model;
    private JPanel panel1;
    private JPanel panel2;
    private JRadioButton radio1;
    private JRadioButton radio2;
    private ButtonGroup buttonGroup;
    private String sqlQuery;

    MoneyView() {
        initComponents();
        panel1.setBorder(BorderFactory.createTitledBorder(null, "Baza", TitledBorder.DEFAULT_JUSTIFICATION,
                TitledBorder.DEFAULT_POSITION, new Font("Dialog", 0, 11)));
        panel2.setBorder(BorderFactory.createTitledBorder(null, "Opcje", TitledBorder.DEFAULT_JUSTIFICATION,
                TitledBorder.DEFAULT_POSITION, new Font("Dialog", 0, 11)));

        add(panel1);
        add(panel2);

        panel1.setBounds(10, 10, 850, 500);
        panel2.setBounds(10, 510, 850, 90);
        radio1.setBounds(183, 35, 150, 20);
        radio2.setBounds(516, 35, 150, 20);

        buttonGroup.add(radio1);
        buttonGroup.add(radio2);
        panel2.add(radio1);
        panel2.add(radio2);

        addRadioButtonListeners();
    }

    private void initComponents() {
        panel1 = new JPanel();
        panel2 = new JPanel(null);
        radio1 = new JRadioButton("Widok jednostkowy");
        radio2 = new JRadioButton("Widok pogrupowany");
        buttonGroup = new ButtonGroup();
    }

    private void addRadioButtonListeners() {
        radio1.addActionListener(e -> {
            sqlQuery = "SELECT * FROM pieniadzeJednostkowe";
            refreshTable();
        });

        radio2.addActionListener(e -> {
            sqlQuery = "SELECT * FROM pieniadzePogrupowane";
            refreshTable();
        });
    }

    private void refreshTable() {
        try {
            if(table != null) {
                setNewModel();
            }
            else {
                table = new MyTable();
                TableRowFilterSupport.forTable(table).searchable(true).apply();
                model = new TableModel(sqlQuery);
                table.setModel(model);

                table.getTableHeader().setReorderingAllowed(false);
                table.setPreferredScrollableViewportSize(new Dimension(800, 440));

                DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
                centerRenderer.setHorizontalAlignment(JLabel.CENTER);
                table.setDefaultRenderer(String.class, centerRenderer);
                JScrollPane scrollPane = new JScrollPane(table);
                panel1.add(scrollPane);
            }
        }
        catch(SQLException ex) {
            JOptionPane.showMessageDialog(null,"Błąd");
        }
    }

    private void setNewModel() {
        try {
            model = new TableModel(sqlQuery);
            table.setModel(model);
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(null,"Błąd");
        }
    }
}
