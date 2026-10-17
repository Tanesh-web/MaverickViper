package com.maverickviper.admin;

import com.maverickviper.config.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin-courses")
public class AdminCoursesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.html");
            return;
        }

        List<String[]> courses = new ArrayList<>();

        String sql = "SELECT course_id, course_name, course_code, description "
                   + "FROM courses ORDER BY course_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                courses.add(new String[]{
                    String.valueOf(rs.getInt("course_id")),
                    rs.getString("course_name"),
                    rs.getString("course_code") == null ? "" : rs.getString("course_code"),
                    rs.getString("description") == null ? "" : rs.getString("description")
                });
            }

            request.setAttribute("courses", courses);
            request.getRequestDispatcher("/admin-courses.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Unable to load courses.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.html");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String courseName = request.getParameter("courseName");
        String courseCode = request.getParameter("courseCode");
        String description = request.getParameter("description");

        if (courseName == null || courseName.trim().isEmpty()) {
            response.sendRedirect("admin-courses?error=empty");
            return;
        }

        String sql = "INSERT INTO courses (course_name, course_code, description) "
                   + "VALUES (?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, courseName.trim());
            ps.setString(2, courseCode == null || courseCode.trim().isEmpty()
                    ? null : courseCode.trim());
            ps.setString(3, description == null || description.trim().isEmpty()
                    ? null : description.trim());

            ps.executeUpdate();

            response.sendRedirect("admin-courses?success=added");

        } catch (Exception e) {
            throw new ServletException("Unable to add course.", e);
        }
    }
}