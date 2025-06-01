import java.sql.*;
import java.util.ArrayList;

// Définition de la classe Salle pour stocker les données d'une salle
class Salle {
    String nSalle;
    String nomSalle;
    int nbPoste;
    String indIP;

    public Salle(String nSalle, String nomSalle, int nbPoste, String indIP) {
        this.nSalle = nSalle;
        this.nomSalle = nomSalle;
        this.nbPoste = nbPoste;
        this.indIP = indIP;
    }

    @Override
    public String toString() {
        return "Salle{" +
               "nSalle='" + nSalle + '\'' +
               ", nomSalle='" + nomSalle + '\'' +
               ", nbPoste=" + nbPoste +
               ", indIP='" + indIP + '\'' +
               '}';
    }
}

public class ExoJDBC {

    private Connection conn = null;
    private String url = "jdbc:mysql://localhost/parc_informatique_db?serverTimezone=UTC"; // Adaptez
    private String utilisateur = "root"; // Adaptez
    private String motDePasse = ""; // Adaptez

    public ExoJDBC() {
        // Constructeur par défaut, la connexion sera établie dans les méthodes ou via une méthode dédiée
    }

    // Méthode pour établir la connexion
    private void connect() throws SQLException, ClassNotFoundException {
        if (conn == null || conn.isClosed()) {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, utilisateur, motDePasse);
            System.out.println("Connexion à la base de données établie pour ExoJDBC.");
        }
    }

    // Méthode pour fermer la connexion
    private void disconnect() {
        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    conn.close();
                    System.out.println("Connexion à la base de données fermée pour ExoJDBC.");
                }
            } catch (SQLException e) {
                System.err.println("Erreur lors de la fermeture de la connexion (ExoJDBC): " + e.getMessage());
                e.printStackTrace();
            }
        }
    }

    /**
     * Retourne sous la forme d'une liste les enregistrements de la table Salle.
     * @return ArrayList<Salle> Une liste d'objets Salle.
     */
    public ArrayList<Salle> getSalles() {
        ArrayList<Salle> listeSalles = new ArrayList<>();
        Statement stmt = null;
        ResultSet rs = null;

        try {
            connect(); // Assurer la connexion
            stmt = conn.createStatement();
            String sql = "SELECT nSalle, nomSalle, nbPoste, indIP FROM Salle";
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                String nSalle = rs.getString("nSalle");
                String nomSalle = rs.getString("nomSalle");
                int nbPoste = rs.getInt("nbPoste");
                String indIP = rs.getString("indIP");
                listeSalles.add(new Salle(nSalle, nomSalle, nbPoste, indIP));
            }
        } catch (SQLException sqle) {
            System.err.println("Erreur SQL dans getSalles: " + sqle.getMessage());
            sqle.printStackTrace();
        } catch (ClassNotFoundException cnfe) {
            System.err.println("Erreur Driver non trouvé dans getSalles: " + cnfe.getMessage());
            cnfe.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                // La connexion est gérée globalement pour la classe, donc pas fermée ici
                // disconnect(); // Décommenter si chaque méthode doit gérer sa propre connexion de A à Z
            } catch (SQLException e) {
                System.err.println("Erreur lors de la fermeture des ressources dans getSalles: " + e.getMessage());
            }
        }
        return listeSalles;
    }

    /**
     * Supprime de la table Salle l'enregistrement de rang passé en paramètre.
     * @param rowIndex Le rang (1-indexed) de la ligne à supprimer.
     */
    public void deleteSalle(int rowIndex) {
        // Vérification que rowIndex est positif
        if (rowIndex <= 0) {
            System.out.println("Le rang doit être un entier positif.");
            return;
        }

        Statement stmt = null;
        ResultSet rs = null;

        try {
            connect(); // Assurer la connexion
            // Créer un Statement scrollable et modifiable
            stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
            String sql = "SELECT nSalle, nomSalle, nbPoste, indIP FROM Salle";
            rs = stmt.executeQuery(sql);

            // Se déplacer à la ligne spécifiée (rowIndex)
            // ResultSet.absolute() est 1-indexed
            if (rs.absolute(rowIndex)) {
                String nSalleSupprime = rs.getString("nSalle");
                System.out.println("Tentative de suppression de la salle: " + nSalleSupprime + " au rang " + rowIndex);
                rs.deleteRow();
                System.out.println("Salle \"" + nSalleSupprime + "\" supprimée avec succès (si pas de contraintes).");
            } else {
                System.out.println("Aucune salle trouvée au rang " + rowIndex + ". Vérifiez le nombre total de salles.");
            }

        } catch (SQLException sqle) {
            if (sqle.getErrorCode() == 1451) { // Code d'erreur MySQL pour violation de contrainte FK
                System.err.println("Erreur SQL (1451): Impossible de supprimer ou mettre à jour une ligne parente : une contrainte de clé étrangère échoue.");
                System.err.println("Détail: " + sqle.getMessage());
            } else {
                System.err.println("Erreur SQL dans deleteSalle: " + sqle.getMessage() + " (Code: " + sqle.getErrorCode() + ")");
                sqle.printStackTrace();
            }
        } catch (ClassNotFoundException cnfe) {
            System.err.println("Erreur Driver non trouvé dans deleteSalle: " + cnfe.getMessage());
            cnfe.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                // disconnect(); // Décommenter si chaque méthode doit gérer sa propre connexion de A à Z
            } catch (SQLException e) {
                System.err.println("Erreur lors de la fermeture des ressources dans deleteSalle: " + e.getMessage());
            }
        }
    }

    public static void main(String[] args) {
        ExoJDBC exo = new ExoJDBC();

        // Test de getSalles()
        System.out.println("--- Test de getSalles() ---");
        ArrayList<Salle> salles = exo.getSalles();
        if (salles.isEmpty()) {
            System.out.println("Aucune salle trouvée.");
        } else {
            System.out.println("Liste des salles :");
            for (Salle salle : salles) {
                System.out.println(salle.toString());
            }
        }
        System.out.println("---------------------------\n");

        // Pour tester deleteSalle(), vous devez connaître un rang valide.
        // Supposons que vous avez ajouté une salle et qu'elle est la dernière.
        // D'abord, comptons le nombre de salles pour obtenir le rang de la dernière.
        // (Note: cette logique est simpliste, une salle ajoutée n'est pas forcément la dernière physiquement
        // si la table n'est pas ordonnée explicitement lors du SELECT dans deleteSalle)
        // Pour un test robuste, il faudrait identifier la salle par sa clé, pas son rang.

        // Exemple d'ajout d'une salle via un client SQL externe pour le test:
        // INSERT INTO Salle (nSalle, nomSalle, nbPoste, indIP) VALUES ('sTest', 'Salle Test Delete', 0, '130.120.80');

        // Puis, pour supprimer cette salle de test (supposons qu'elle est la N-ième salle)
        // Il faudrait connaître N. Pour un test simple, si vous savez qu'il y a, disons, 8 salles
        // et que vous en avez ajouté une 9ème que vous voulez supprimer :
        // exo.deleteSalle(9);

        // Exemple: supprimer la première salle (rang 1). Attention, cela peut échouer si elle a des postes liés.
        System.out.println("--- Test de deleteSalle(int) ---");
        System.out.println("Avant d'exécuter deleteSalle, assurez-vous d'avoir une salle à supprimer (par exemple, 'sTest').");
        System.out.println("Si cette salle a des postes (enregistrements fils dans la table Poste), sa suppression directe échouera à cause des contraintes de clé étrangère (erreur 1451).");
        System.out.println("La méthode deleteSalle est conçue pour afficher cette erreur 1451 spécifiquement.");
        
        // Pour vraiment tester, vous pourriez avoir besoin de connaître le nombre actuel de salles.
        // ArrayList<Salle> sallesAvantDelete = exo.getSalles();
        // int rangASupprimer = sallesAvantDelete.size(); // Supprimer la dernière si ajoutée récemment
        // if (rangASupprimer > 0) {
        //     System.out.println("Tentative de suppression de la salle au rang: " + rangASupprimer);
        //     exo.deleteSalle(rangASupprimer); 
        // } else {
        //     System.out.println("Pas de salle à supprimer avec cette logique.");
        // }

        // Afficher à nouveau les salles pour voir le résultat de la suppression
        // System.out.println("\nListe des salles après tentative de suppression:");
        // salles = exo.getSalles();
        // if (salles.isEmpty()) {
        //     System.out.println("Aucune salle trouvée.");
        // } else {
        //     for (Salle salle : salles) {
        //         System.out.println(salle.toString());
        //     }
        // }

        // N'oubliez pas de fermer la connexion globalement lorsque l'application se termine
        // ou si ExoJDBC n'est plus utilisé.
        exo.disconnect();
    }
} 