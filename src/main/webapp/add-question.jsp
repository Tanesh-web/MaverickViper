<%@page import="java.util.List"%>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.html");
        return;
    }

    List<String[]> courses =
        (List<String[]>) request.getAttribute("courses");

    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Questions | Maverick Viper</title>

    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
        }

        body {
            background: #180811;
            color: white;
            padding: 30px 15px;
        }

        .container {
            max-width: 850px;
            margin: auto;
        }

        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 30px;
        }

        h1, h2 {
            color: #f2c5d3;
        }

        h1 {
            margin-bottom: 8px;
        }

        .subtitle {
            color: #bdaab1;
        }

        a {
            color: #f2a9c0;
            text-decoration: none;
        }

        .panel {
            background: #2b101d;
            border: 1px solid #633047;
            border-radius: 12px;
            padding: 25px;
        }

        h2 {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin: 17px 0 8px;
            color: #e6c5d2;
        }

        input, textarea, select {
            width: 100%;
            padding: 13px;
            background: #180811;
            color: white;
            border: 1px solid #633047;
            border-radius: 7px;
            outline: none;
        }

        textarea {
            min-height: 110px;
            resize: vertical;
        }

        select option {
            background: #2b101d;
        }

        .correct-title {
            margin-top: 22px;
            color: #f2c5d3;
        }

        .correct-options {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
            margin-top: 12px;
        }

        .correct-options label {
            background: #180811;
            border: 1px solid #633047;
            border-radius: 7px;
            padding: 12px;
            margin: 0;
            cursor: pointer;
        }

        .correct-options input {
            width: auto;
            margin-right: 7px;
            accent-color: #e83b6b;
        }

        button {
            margin-top: 25px;
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 7px;
            background: #c92857;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
        }

        button:hover {
            background: #e83b6b;
        }

        .success {
            color: #79e6a2;
            margin-bottom: 15px;
        }

        .error {
            color: #ff9292;
            margin-bottom: 15px;
        }

        @media(max-width: 550px) {
            .correct-options {
                grid-template-columns: repeat(2, 1fr);
            }

            .panel {
                padding: 18px;
            }
        }
    </style>
</head>

<body>
<div class="container">

    <header>
        <div>
            <h1>Add Questions</h1>
            <p class="subtitle">Add NPTEL multiple-choice questions</p>
        </div>

        <a href="admin-dashboard">Back to Dashboard</a>
    </header>

    <section class="panel">

        <h2>Question Details</h2>

        <% if ("added".equals(success)) { %>
            <p class="success">Question added successfully!</p>
        <% } %>

        <% if ("invalid".equals(error)) { %>
            <p class="error">Please fill all fields correctly.</p>
        <% } %>

        <form action="add-question" method="post">

            <label>Select Course</label>
            <select name="courseId" required>
                <option value="">Choose a course</option>

                <% if (courses != null) {
                    for (String[] course : courses) { %>
                        <option value="<%= course[0] %>">
                            <%= course[1] %>
                        </option>
                <%  }
                   } %>
            </select>

            <label>NPTEL Week Number</label>
            <input type="number" name="weekNumber"
                   min="1" max="52" placeholder="Example: 1" required>

            <label>Question</label>
            <textarea name="questionText"
                      placeholder="Enter your question here"
                      required></textarea>

            <label>Option A</label>
            <input type="text" name="optionA" required>

            <label>Option B</label>
            <input type="text" name="optionB" required>

            <label>Option C</label>
            <input type="text" name="optionC" required>

            <label>Option D</label>
            <input type="text" name="optionD" required>

            <p class="correct-title">Select Correct Answer</p>

            <div class="correct-options">
                <label>
                    <input type="radio" name="correctOption"
                           value="A" required> A
                </label>

                <label>
                    <input type="radio" name="correctOption"
                           value="B"> B
                </label>

                <label>
                    <input type="radio" name="correctOption"
                           value="C"> C
                </label>

                <label>
                    <input type="radio" name="correctOption"
                           value="D"> D
                </label>
            </div>

            <button type="submit">Save Question</button>

        </form>
    </section>

</div>
</body>
</html>