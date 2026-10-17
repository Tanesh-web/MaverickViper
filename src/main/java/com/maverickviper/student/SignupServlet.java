package com.maverickviper.student;

import com.maverickviper.dao.StudentDAO;
import com.maverickviper.model.Student;
import com.maverickviper.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("signup.html");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (name == null || email == null || password == null || confirmPassword == null ||
                name.trim().isEmpty() || email.trim().isEmpty() || password.isEmpty()) {
            response.sendRedirect("signup.html?error=empty");
            return;
        }

        name = name.trim();
        email = email.trim().toLowerCase();

        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            response.sendRedirect("signup.html?error=invalid_email");
            return;
        }

        if (password.length() < 6) {
            response.sendRedirect("signup.html?error=short_password");
            return;
        }

        if (!password.equals(confirmPassword)) {
            response.sendRedirect("signup.html?error=mismatch");
            return;
        }

        // Check if student with this email already exists
        Student existing = studentDAO.findByEmail(email);
        if (existing != null) {
            response.sendRedirect("signup.html?error=exists");
            return;
        }

        try {
            String hash = PasswordUtil.hashPassword(password);
            Student newStudent = new Student();
            newStudent.setFullName(name);
            newStudent.setEmail(email);
            newStudent.setPasswordHash(hash);

            boolean created = studentDAO.createStudent(newStudent);
            if (created) {
                response.sendRedirect("login.html?registered=true");
            } else {
                response.sendRedirect("signup.html?error=failed");
            }
        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                response.sendRedirect("signup.html?error=exists");
            } else {
                response.sendRedirect("signup.html?error=db_error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("signup.html?error=unknown");
        }
    }
}
