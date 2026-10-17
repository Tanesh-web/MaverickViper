package com.maverickviper.config;

import java.sql.Connection;
import java.sql.SQLException;

public class DBTest {

    public static void main(String[] args) {

        Connection connection = DBConnection.getConnection();

        if (connection != null) {

            System.out.println("================================");
            System.out.println("       MAVERICK VIPER");
            System.out.println("================================");
            System.out.println("MySQL Connection Successful!");

            try {
                connection.close();
                System.out.println("Connection closed successfully.");

            } catch (SQLException ex) {
                System.out.println("Error closing connection: " + ex.getMessage());
            }

        } else {

            System.out.println("MySQL Connection Failed!");

        }
    }
}