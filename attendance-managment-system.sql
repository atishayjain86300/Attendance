import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.event.*;
import java.sql.*;
import java.util.Vector;

public class Attendance {
    private JTextField nameData;
    private JTextField totalClasses;
    private JTable table1;
    private JButton ADDRECORDButton;
    private JButton UPDATERECORDButton;
    private JPanel mainPanel;
    private JComboBox<String> subject;
    private JTextField attendance;

    public Attendance() {
        JFrame frame = new JFrame("Attendance Management");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setContentPane(mainPanel);
        frame.pack();
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);

        ADDRECORDButton.addActionListener(e -> addRecord());

        table1.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                DefaultTableModel dm = (DefaultTableModel) table1.getModel();
                int rowIndex = table1.getSelectedRow();
                nameData.setText(dm.getValueAt(rowIndex, 0).toString());
                attendance.setText(dm.getValueAt(rowIndex, 3).toString());
                totalClasses.setText(dm.getValueAt(rowIndex, 2).toString());
            }
        });

        tableData();
    }

    private void addRecord() {
        if (nameData.getText().isEmpty() || attendance.getText().isEmpty()) {
            JOptionPane.showMessageDialog(null, "Please Fill NAME and Total Classes Fields to add Record.");
            return;
        }

        try {
            String selectedSubject = (String) subject.getSelectedItem();
            String sql = "INSERT INTO attendance (NAME, SUBJECT, TOTAL_CLASSES, CLASSES_ATTENDED, TOTAL_ATTENDANCE) VALUES (?, ?, ?, ?, ?)";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/intern", "root", "root");
                 PreparedStatement statement = connection.prepareStatement(sql)) {

                double attend = (Double.parseDouble(attendance.getText()) / Double.parseDouble(totalClasses.getText())) * 100.0;
                statement.setString(1, nameData.getText());
                statement.setString(2, selectedSubject);
                statement.setString(3, totalClasses.getText());
                statement.setString(4, attendance.getText());
                statement.setString(5, String.format("%.2f", attend) + "%");
                statement.executeUpdate();
                JOptionPane.showMessageDialog(null, "STUDENT ADDED SUCCESSFULLY");
                attendance.setText("");
                tableData();
            }
        } catch (ClassNotFoundException | SQLException ex) {
            JOptionPane.showMessageDialog(null, ex.getMessage());
        }
    }

    private void tableData() {
        try {
            String query = "SELECT * FROM attendance";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/intern", "root", "root");
                 Statement statement = connection.createStatement();
                 ResultSet resultSet = statement.executeQuery(query)) {

                table1.setModel(buildTableModel(resultSet));
            }
        } catch (ClassNotFoundException | SQLException ex) {
            JOptionPane.showMessageDialog(null, ex.getMessage());
        }
    }

    private DefaultTableModel buildTableModel(ResultSet rs) throws SQLException {
        ResultSetMetaData metaData = rs.getMetaData();
        int columnCount = metaData.getColumnCount();

        Vector<String> columnNames = new Vector<>();
        for (int column = 1; column <= columnCount; column++) {
            columnNames.add(metaData.getColumnName(column));
        }

        Vector<Vector<Object>> data = new Vector<>();
        while (rs.next()) {
            Vector<Object> vector = new Vector<>();
            for (int columnIndex = 1; columnIndex <= columnCount; columnIndex++) {
                vector.add(rs.getObject(columnIndex));
            }
            data.add(vector);
        }

        return new DefaultTableModel(data, columnNames);
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(Attendance::new);
    }
}
