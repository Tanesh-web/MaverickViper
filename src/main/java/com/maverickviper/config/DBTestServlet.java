package com.maverickviper.config;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;

@WebServlet("/db-test")
public class DBTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {

            out.println("<html><body>");
            out.println("<h1>MAVERICK VIPER</h1>");

            Connection connection = DBConnection.getConnection();

            if (connection != null) {

                out.println("<h2 style='color:green;'>");
                out.println("MySQL Connection Successful!");
                out.println("</h2>");

                connection.close();

            } else {

                out.println("<h2 style='color:red;'>");
                out.println("MySQL Connection Failed!");
                out.println("</h2>");

            }

            out.println("</body></html>");

        } catch (Exception ex) {

            response.getWriter().println(
                    "Database Error: " + ex.getMessage()
            );

        }
    }
}