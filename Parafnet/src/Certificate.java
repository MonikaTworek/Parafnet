import javax.swing.*;
import javax.swing.border.TitledBorder;
import java.awt.*;
import java.sql.*;
import java.util.Vector;

class Certificate extends JLayeredPane {
    private JPanel panel1;
    private JPanel panel2;
    private JButton button1;
    private JLabel textArea;
    private JComboBox<String> peopleList;
    private JComboBox<String> sacramentList;
    private JLabel label1;
    private JLabel label2;

    Certificate() {
        initComponents();
        panel1.setBorder(BorderFactory.createTitledBorder(null, "Zaświadczenie", TitledBorder.DEFAULT_JUSTIFICATION,
                TitledBorder.DEFAULT_POSITION, new Font("Dialog", 0, 11)));

        panel2.setBorder(BorderFactory.createTitledBorder(null, "Operacje", TitledBorder.DEFAULT_JUSTIFICATION,
                TitledBorder.DEFAULT_POSITION, new Font("Dialog", 0, 11)));

        panel1.setBounds(10, 10, 850, 400);
        panel2.setBounds(10, 420, 850, 180);
        textArea.setBounds(15, 20, 820, 365);
        peopleList.setBounds(90, 27, 200, 20);
        sacramentList.setBounds(90, 75, 200, 20);
        label1.setBounds(10, 20, 80, 30);
        label2.setBounds(10, 70, 80, 30);
        button1.setBounds(70, 130, 100, 30);

        add(panel1);
        add(panel2);
        panel1.add(textArea);
        panel2.add(button1);
        panel2.add(peopleList);
        panel2.add(sacramentList);
        panel2.add(label1);
        panel2.add(label2);

        setComboBoxes();
        addListeners();
    }

    private void initComponents() {
        panel1 = new JPanel(null);
        panel2 = new JPanel(null);
        textArea = new JLabel();
        button1 = new JButton("Wygeneruj");
        peopleList = new JComboBox<>();
        sacramentList = new JComboBox<>();
        label1 = new JLabel("Wierny:");
        label2 = new JLabel("Sakrament:");

//        textArea.setEditable(false);
    }

    private void addListeners() {
        button1.addActionListener(e -> {
            String human = peopleList.getSelectedItem().toString();
            String sacrament = sacramentList.getSelectedItem().toString();

            int index = human.indexOf(":");
            human = human.substring(0, (index-1));


            int s = 0;
            if(sacrament.equals("Chrzest"))
                s = 1;
            else if(sacrament.equals("Komunia Święta"))
                s = 2;
            else if(sacrament.equals("Bierzmowanie"))
                s = 3;
            else if(sacrament.equals("Małżeństwo"))
                s = 5;
            else
                s = 4;

            int h = Integer.parseInt(human);

            System.out.println("Wybrano " + human + ", " + s);
            createCertificate(h, s);
        });
    }

    private void setComboBoxes() {
        Vector<String> data1 = new Vector<>();
        Vector<String> data2 = new Vector<>();

        try {
            String sql1 = "SELECT Nazwa FROM BazaSakramentow";
            Statement stmt = ConnectionWithServer.getConnection().createStatement();
            ResultSet rs1 = stmt.executeQuery(sql1);
            while (rs1.next()) {
                data1.add(rs1.getString("Nazwa"));
            }

            String sql2 = "SELECT * FROM Wierny";
            ResultSet rs2 = stmt.executeQuery(sql2);
            while (rs2.next()) {
                String d = rs2.getString("IDWiernego") + " : " + rs2.getString("Imiona") + " " + rs2.getString("Nazwisko");
                data2.add(d);
            }
        }
        catch(SQLException e) {
            JOptionPane.showMessageDialog(null,"Błąd");
        }

        sacramentList.setModel(new DefaultComboBoxModel<>(data1));
        peopleList.setModel(new DefaultComboBoxModel<>(data2));

        sacramentList.setSelectedIndex(-1);
        peopleList.setSelectedIndex(-1);
    }

    private void createCertificate(int idH, int idS) {
        textArea.setText("");
        Connection conn = ConnectionWithServer.getConnection();
        try {
            PreparedStatement stmt = conn.prepareStatement("SELECT * FROM Zaswiadczenie(?, ?)");
            stmt.setInt(1, idH);
            stmt.setInt(2, idS);
            ResultSet rs = stmt.executeQuery();
            int ok = 0;
            while(rs.next()) {
                ok = 1;
                String names = rs.getString(1);
                String surname = rs.getString(2);
                String dateOfBirth = rs.getString(3);
                String dateOfSacrament = rs.getString(4);
                String nameOfSacrament = rs.getString(5);

                textArea.setFont(new Font("Dialog", 0, 24));
                textArea.setText("<html>" + names + " " + surname + " urodzony " + dateOfBirth +
                        " przyjął/przyjęła " + nameOfSacrament + " dnia " + dateOfSacrament +
                        "<br><p align=\"right\">miejsce na podpis:</p></html>");
            }
            if(ok == 0) {
                JOptionPane.showMessageDialog(this, "Brak takiego sakramentu dla wskazanego wiernego");
            }
        } catch (SQLException se) {
            JOptionPane.showMessageDialog(null,"Błąd");
        }
    }
}
