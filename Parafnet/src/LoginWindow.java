import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

class LoginWindow extends JFrame {
    private JTextField textUser;
    private JTextField textPass;

    LoginWindow() {
        super("Parafnet Autentification");
        JButton buttonLogin = new JButton("Zaloguj");
        JPanel panelLogin = new JPanel();
        textUser = new JTextField(15);
        textPass = new JPasswordField(15);
        JLabel username1 = new JLabel("Użytkownik: ");
        JLabel password1 = new JLabel("Hasło: ");

        setBounds(500, 400, 300, 200);
        panelLogin.setLayout (null);

        textUser.setBounds(110,29,150,20);
        textPass.setBounds(110,67,150,20);
        username1.setBounds(30,30,80,20);
        password1.setBounds(30,65,80,20);
        buttonLogin.setBounds(100,130,100,20);

        panelLogin.add(textUser);
        panelLogin.add(textPass);
        panelLogin.add(username1);
        panelLogin.add(password1);
        panelLogin.add(buttonLogin);

        getContentPane().add(panelLogin);
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        setVisible(true);
        setResizable(false);

        buttonLogin.addActionListener(new ButtonListener());
    }

    class ButtonListener implements ActionListener {

        @Override
        public void actionPerformed(ActionEvent e) {
            String username = textUser.getText();
            String password = textPass.getText();

            System.out.println("user: " + username + ", password: " + password);

            if(username.equals("") || password.equals(""))
                JOptionPane.showMessageDialog(null,"Wprowadź nazwę użytkownika oraz hasło");

            else {
                if(username.equals("admin") && password.equals("Guzik")) {
                    try {
                        boolean userLogged = ConnectionWithServer.logIn(username, password);
                        if (userLogged) {
                            System.out.println("User logged");
                            new MainWindow();
                            dispose();
                        } else
                            JOptionPane.showMessageDialog(null, "Nieprawidłowa nazwa użytkownika lub hasło");
                    } catch (ConnectionFailedException ex) {
                        JOptionPane.showMessageDialog(null, "Connection failed. Please, try again");
                    }
                }
                else {
                    JOptionPane.showMessageDialog(null, "Nieprawidłowa nazwa użytkownika lub hasło");
                }
            }
            textUser.setText("");
            textPass.setText("");
            textUser.requestFocus();

        }
    }
}