package com.maverickviper.admin;

import com.maverickviper.dao.WeekDAO;
import com.maverickviper.model.Week;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin-weeks")
public class AdminWeeksServlet extends HttpServlet {

    private final WeekDAO weekDAO = new WeekDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.html");
            return;
        }

        int courseId = 1;
        List<Week> weeks = weekDAO.getAllWeeks(courseId);
        request.setAttribute("weeks", weeks);

        String editIdParam = request.getParameter("editId");
        if (editIdParam != null && !editIdParam.trim().isEmpty()) {
            try {
                int editId = Integer.parseInt(editIdParam.trim());
                Week editWeek = weekDAO.getWeekById(editId);
                request.setAttribute("editWeek", editWeek);
            } catch (NumberFormatException ignored) {}
        }

        request.getRequestDispatcher("/admin-weeks.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.html");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        int courseId = 1;

        if ("delete".equalsIgnoreCase(action)) {
            try {
                int weekId = Integer.parseInt(request.getParameter("weekId"));
                boolean deleted = weekDAO.deleteWeek(weekId);
                if (deleted) {
                    response.sendRedirect("admin-weeks?success=deleted");
                } else {
                    response.sendRedirect("admin-weeks?error=has_questions");
                }
            } catch (Exception e) {
                response.sendRedirect("admin-weeks?error=delete_failed");
            }
            return;
        }

        String weekNumberParam = request.getParameter("weekNumber");
        String weekName = request.getParameter("weekName");
        String weekIdParam = request.getParameter("weekId");

        if (weekNumberParam == null || weekName == null || weekName.trim().isEmpty()) {
            response.sendRedirect("admin-weeks?error=empty");
            return;
        }

        try {
            int weekNumber = Integer.parseInt(weekNumberParam.trim());

            if ("update".equalsIgnoreCase(action) && weekIdParam != null) {
                int weekId = Integer.parseInt(weekIdParam.trim());
                Week w = new Week();
                w.setWeekId(weekId);
                w.setWeekNumber(weekNumber);
                w.setWeekName(weekName.trim());
                boolean updated = weekDAO.updateWeek(w);
                if (updated) {
                    response.sendRedirect("admin-weeks?success=updated");
                } else {
                    response.sendRedirect("admin-weeks?error=update_failed");
                }
            } else {
                // Check if already exists
                Week existing = weekDAO.getWeekByNumber(courseId, weekNumber);
                if (existing != null) {
                    response.sendRedirect("admin-weeks?error=week_exists");
                    return;
                }

                Week newWeek = new Week();
                newWeek.setCourseId(courseId);
                newWeek.setWeekNumber(weekNumber);
                newWeek.setWeekName(weekName.trim());
                boolean added = weekDAO.addWeek(newWeek);
                if (added) {
                    response.sendRedirect("admin-weeks?success=added");
                } else {
                    response.sendRedirect("admin-weeks?error=add_failed");
                }
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("admin-weeks?error=invalid_number");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin-weeks?error=failed");
        }
    }
}
