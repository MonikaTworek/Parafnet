import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionListener;

class MainWindow extends JFrame {
    private JTabbedPane jTabbedPane1;

    MainWindow() {
        super("Parafnet");
        Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        setBounds((screenSize.width - 900) / 2, (screenSize.height - 700) / 2, 900, 700);

        jTabbedPane1 = new JTabbedPane();
        BrowseDatabase jLayeredPane1 = new BrowseDatabase();
        Agenda jLayeredPane2 = new Agenda();
        Certificate jLayeredPane3 = new Certificate();
        Carol jLayeredPane4 = new Carol();
        MoneyView jLayeredPane5 = new MoneyView();

        jTabbedPane1.setFont(new Font("Dialog", 0, 12));
        JPanel panel = new JPanel(null);
        panel.add(jTabbedPane1);
        jTabbedPane1.setBounds(10, 10, 870, 630);

        setLayeredPane(jLayeredPane1, "Przeglądanie i modyfikacja bazy");
        setLayeredPane(jLayeredPane2, "Terminarz");
        setLayeredPane(jLayeredPane3, "Zaświadczenia");
        setLayeredPane(jLayeredPane4, "Kolęda");
        setLayeredPane(jLayeredPane5, "Finanse");

        JMenuBar jMenuBar1 = new JMenuBar();
        JMenu jMenu1 = new JMenu();
//        JMenu jMenu2 = new JMenu();
//        JMenu jMenu3 = new JMenu();
        JMenuItem jMenuItem1 = new JMenuItem();
        JMenuItem jMenuItem2 = new JMenuItem();

        jMenu1.setText("Plik");
        setMenuItems(jMenuItem1, jMenu1, "Wyloguj", e -> ConnectionWithServer.logOut());
        jMenu1.addSeparator();
        setMenuItems(jMenuItem2, jMenu1, "Zakończ", e -> {
            String p = "Czy na pewno chcesz zakończyć? ";
            int c = JOptionPane.showConfirmDialog(null, p, "Informacja",
                    JOptionPane.YES_NO_OPTION, JOptionPane.INFORMATION_MESSAGE);
            if (c == JOptionPane.OK_OPTION)
                System.exit(1);
        });

//        jMenu2.setText("Opcje");
//        jMenu3.setText("Pomoc");
        jMenuBar1.add(jMenu1);
//        jMenuBar1.add(jMenu2);
//        jMenuBar1.add(jMenu3);
        setJMenuBar(jMenuBar1);

        getContentPane().add(panel);
        //TODO listener do zamykania - konieczny logout i JOptionPane z potwierdzeniem
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        setVisible(true);
        setResizable(false);
    }

    private void setLayeredPane(JLayeredPane layer, String name) {
        layer.setBackground(new Color(238, 238, 238));
        layer.setOpaque(true);
        jTabbedPane1.addTab(name, layer);
    }

    private void setMenuItems(JMenuItem item, JMenu menu, String name, ActionListener listener) {
        item.setFont(new Font("Dialog", 0, 12));
        item.setText(name);
        menu.add(item);
        item.addActionListener(listener);
    }
}
