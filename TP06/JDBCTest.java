import java.awt.*;
import java.awt.event.*;
import java.sql.*;
public class JDBCTest extends Panel
implements ActionListener
{
    TextField nomDriver;
    TextField urlConnection;
    TextField nomLogin;
    TextField motPasse;
    Button boutonConnection;
    TextField requeteSQL;
    List resultatRequete;
    Button boutonExecuter;

    // Variables pour la connexion
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    public JDBCTest()
    {
        Panel haut;
        Panel bas;
        haut = new Panel();
        bas = new Panel();
        boutonConnection = new Button("Connection");
        boutonConnection.addActionListener(this);
        boutonExecuter = new Button("Execution");
        boutonExecuter.addActionListener(this);

        Panel p1 = new Panel();
        p1.setLayout(new GridLayout(4, 2));
        p1.add(new Label("Driver :"));
        p1.add(nomDriver = new TextField(32));
        nomDriver.setText("com.mysql.cj.jdbc.Driver"); // Valeur par défaut pour MySQL
        p1.add(new Label("URL jdbc :"));
        p1.add(urlConnection = new TextField(32));
        urlConnection.setText("jdbc:mysql://localhost/parc_informatique_db?serverTimezone=UTC"); // Adaptez localhost et parc_informatique_db
        p1.add(new Label("login :"));
        p1.add(nomLogin = new TextField(32));
        p1.add(new Label("password :"));
        p1.add(motPasse = new TextField(32));
        motPasse.setEchoChar('*'); // Masquer le mot de passe

        haut.setLayout(new BorderLayout());
        haut.add(p1, BorderLayout.NORTH);
        haut.add(boutonConnection, BorderLayout.SOUTH);

        Panel p2 = new Panel();
        p2.setLayout(new BorderLayout());
        p2.add(new Label("requete"), BorderLayout.WEST);
        p2.add(requeteSQL = new TextField(32), BorderLayout.CENTER);

        Panel p3 = new Panel();
        p3.setLayout(new BorderLayout());
        p3.add(p2, BorderLayout.NORTH);
        p3.add(boutonExecuter, BorderLayout.SOUTH);

        bas.setLayout(new BorderLayout());
        bas.add(p3, BorderLayout.NORTH);
        bas.add(resultatRequete = new List(20));

        setLayout(new BorderLayout());
        add(haut, BorderLayout.NORTH);
        add(bas, BorderLayout.CENTER);
    }

    public void actionPerformed(ActionEvent evt)
    {
        resultatRequete.removeAll(); // Effacer les résultats précédents

        if (evt.getSource() == boutonConnection) {
            try {
                // Fermer la connexion existante si elle est ouverte
                if (conn != null && !conn.isClosed()) {
                    conn.close();
                    resultatRequete.add("Ancienne connexion fermée.");
                }

                // Charger le driver
                Class.forName(nomDriver.getText());
                resultatRequete.add("Driver chargé: " + nomDriver.getText());

                // Établir la connexion
                conn = DriverManager.getConnection(urlConnection.getText(), nomLogin.getText(), motPasse.getText());
                resultatRequete.add("Connexion établie à: " + urlConnection.getText());
                boutonExecuter.setEnabled(true); // Activer le bouton d'exécution

            } catch (ClassNotFoundException cnfe) {
                resultatRequete.add("Erreur driver: " + cnfe.getMessage());
                cnfe.printStackTrace();
            } catch (SQLException sqle) {
                resultatRequete.add("Erreur SQL connexion: " + sqle.getMessage());
                resultatRequete.add("SQLState: " + sqle.getSQLState());
                resultatRequete.add("VendorError: " + sqle.getErrorCode());
                sqle.printStackTrace();
            } catch (Exception e) {
                resultatRequete.add("Autre erreur connexion: " + e.getMessage());
                e.printStackTrace();
            }
        } else if (evt.getSource() == boutonExecuter) {
            if (conn == null) {
                resultatRequete.add("Veuillez d'abord établir une connexion.");
                return;
            }
            String sql = requeteSQL.getText();
            if (sql == null || sql.trim().isEmpty()) {
                resultatRequete.add("Veuillez entrer une requête SQL.");
                return;
            }

            try {
                stmt = conn.createStatement();
                boolean hasResultSet = stmt.execute(sql);

                if (hasResultSet) {
                    rs = stmt.getResultSet();
                    ResultSetMetaData metaData = rs.getMetaData();
                    int columnCount = metaData.getColumnCount();

                    // Afficher les noms des colonnes
                    String header = "";
                    for (int i = 1; i <= columnCount; i++) {
                        header += metaData.getColumnLabel(i) + "\t";
                    }
                    resultatRequete.add(header);
                    resultatRequete.add("-------------------------------------");

                    // Afficher les lignes de résultat
                    while (rs.next()) {
                        String row = "";
                        for (int i = 1; i <= columnCount; i++) {
                            row += rs.getString(i) + "\t";
                        }
                        resultatRequete.add(row);
                    }
                    rs.close();
                } else {
                    int updateCount = stmt.getUpdateCount();
                    resultatRequete.add("Requête de mise à jour exécutée. " + updateCount + " lignes affectées.");
                }
                stmt.close();
            } catch (SQLException sqle) {
                resultatRequete.add("Erreur SQL exécution: " + sqle.getMessage());
                resultatRequete.add("SQLState: " + sqle.getSQLState());
                resultatRequete.add("VendorError: " + sqle.getErrorCode());
                sqle.printStackTrace();
            } catch (Exception e) {
                resultatRequete.add("Autre erreur exécution: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] arg)
    {
        JDBCTest test;
        Frame f = new Frame();
        f.setTitle("Testeur JDBC"); // Donner un titre à la fenêtre
        f.setSize(600, 500); // Augmenter un peu la taille pour la lisibilité
        test = new JDBCTest( );
        f.add(test, BorderLayout.CENTER);
        f.addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e)
            {
                // Fermer la connexion proprement à la fermeture de la fenêtre
                if (test.conn != null) {
                    try {
                        if (!test.conn.isClosed()) {
                            test.conn.close();
                            System.out.println("Connexion JDBC fermée.");
                        }
                    } catch (SQLException sqle) {
                        System.err.println("Erreur lors de la fermeture de la connexion: " + sqle.getMessage());
                        sqle.printStackTrace();
                    }
                }
                System.exit(0);
            }
        } );
        f.setVisible(true);
    }
} 