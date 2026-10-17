package com.maverickviper.admin;

import com.maverickviper.config.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/admin-setup")
public class AdminSetupServlet extends HttpServlet {

    private boolean adminExists() throws Exception {
        String sql = "SELECT COUNT(*) FROM admins";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            rs.next();
            return rs.getInt(1) > 0;
        }
    }

    private String hashPassword(String password) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash = md.digest(password.getBytes(StandardCharsets.UTF_8));

        StringBuilder result = new StringBuilder();

        for (byte b : hash) {
            result.append(String.format("%02x", b));
        }

        return result.toString();
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        try {
            if (adminExists()) {
                response.getWriter().println(
                    "Admin account already exists. Setup is disabled."
                );
                return;
            }

            PrintWriter out = response.getWriter();

            out.println("<h2>Create First Admin Account</h2>");
            out.println("<form method='post' action='admin-setup'>");
            out.println("Username: <input type='text' name='username' required><br><br>");
            out.println("Password: <input type='password' name='password' required><br><br>");
            out.println("<button type='submit'>Create Admin</button>");
            out.println("</form>");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null
                || username.trim().isEmpty() || password.length() < 12) {

            response.getWriter().println(
                "Enter a username and a password of at least 12 characters."
            );
            return;
        }

        try {
            if (adminExists()) {
                response.getWriter().println(
                    "An admin account already exists. Setup is disabled."
                );
                return;
            }

            String sql = "INSERT INTO admins (username, password_hash) VALUES (?, ?)";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setString(1, username.trim());
                ps.setString(2, hashPassword(password));
                ps.executeUpdate();
            }

            response.getWriter().println(
                "Admin account created successfully. "
                + "<a href='admin-login.html'>Go to Admin Login</a>"
            );

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}