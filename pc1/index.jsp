
<%@page import="java.text.DateFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.util.Calendar"%>
<%@ page import = "java.util.Date" %> 
<%-- 
    Document   : index
    Created on : 21/09/2020, 11:22:05 AM
    Author     : JR
--%>
<%@ page import="java.sql.*" %> 
<%@ page import="java.io.*" %> 
<%! Connection con = null; %> 
<%! Statement st = null; %> 
<%! ResultSet rs = null;%> 
<%
    String diasSemana[] = {"DOMINGO", "LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES", "SÁBADO"};
    try {
        String connectionURL = "jdbc:mysql://localhost:3306/agenda";
        Class.forName("com.mysql.jdbc.Driver").newInstance();
        con = DriverManager.getConnection(connectionURL, "root", "");
        if (!con.isClosed()) {
            //out.println("Successfully connected to " + "MySQL server using TCP/IP...");
        }
    } catch (Exception ex) {
        out.println("Unable to connect to database.");
    }
    st = con.createStatement();
    DateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
    DateFormat dateFormatQSL = new SimpleDateFormat("yyyy-MM-dd");
    Calendar hoy = Calendar.getInstance();
    Date hoydia = hoy.getTime();
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0"> 
        <title>AGENDA</title>
        <link href="agenda.css" rel="stylesheet" type="text/css"/>

    </head>
    <body>
        <div class="contenedor">
            <a id="n-tarea" class="btn-agregar" href="?op=nuevo">NUEVA TAREA</a>
            <table border="1" id="semana" rules="all">
                <thead>
                    <tr>
                        <th>Hora</th>
                            <%
                                out.print("<th class=hoydia>" + diasSemana[(hoydia.getDay())] + "<br><label>" + dateFormat.format(hoydia) + "</label></th>");
                                for (int i = 0; i < 6; i++) {

                                    hoy.add(Calendar.DATE, 1);
                                    Date utilDate = hoy.getTime();
                                    out.print("<th>" + diasSemana[(utilDate.getDay())] + "<br><label>" + dateFormat.format(utilDate) + "</label></th>");

                                }

                            %>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <%                                rs = st.executeQuery("SELECT hora_inicio,hora_fin  FROM tareas WHERE fecha='" + dateFormatQSL.format(hoydia) + "' ORDER BY hora_inicio");
                                while (rs.next()) {
                                    out.println(rs.getTime("hora_inicio") + "<br>");
                                }
                            %>
                        </td>
                        <td>
                            <%
                                rs = st.executeQuery("SELECT * FROM tareas WHERE fecha='" + dateFormatQSL.format(hoydia) + "'ORDER BY hora_inicio");
                                while (rs.next()) {
                                    String prioridad = rs.getString("prioridad");
                                    String nombre = rs.getString("nombre");
                                    int id = rs.getInt("id");
                                    switch (prioridad) {
                                        case "A":
                                            prioridad = "normal";
                                            break;
                                        case "B":
                                            prioridad = "importante";
                                            break;
                                        case "C":
                                            prioridad = "urgente";
                                            break;
                                    }
                                    out.println("<div class='tarea " + prioridad + "'><a href=?op=editar&id=" + id + ">Ver</a>" + nombre + "</div>");
                                }
                            %>
                        </td>
                        <%
                            hoy = Calendar.getInstance();
                            for (int i = 0; i < 6; i++) {
                                hoy.add(Calendar.DATE, 1);
                                Date utilDate = hoy.getTime();
                                rs = st.executeQuery("SELECT * FROM tareas WHERE fecha='" + dateFormatQSL.format(utilDate) + "'");
                                out.println("<td>");
                                while (rs.next()) {
                                    String prioridad_s = rs.getString("prioridad");
                                    String nombre_s = rs.getString("nombre");
                                    int id = rs.getInt("id");
                                    switch (prioridad_s) {
                                        case "A":
                                            prioridad_s = "normal";
                                            break;
                                        case "B":
                                            prioridad_s = "importante";
                                            break;
                                        case "C":
                                            prioridad_s = "urgente";
                                            break;
                                    }
                                    out.println("<div class='tarea " + prioridad_s + "'> <a href=?op=editar&id=" + id + ">Ver</a>" + nombre_s + "</div>");
                                }
                                out.println("</td>");
                            }

                        %>


                    </tr>

                </tbody>
            </table>
        </div>

        <%            if (request.getParameter("op") != null) {
                switch (request.getParameter("op")) {
                    case "nuevo":
        %>
        <div class="full">
            <div class="centrar">
                <a href="index.jsp"class="cerrar">Cerrar</a>
                <form method="POST" class="f-n-tarea">
                    <h2 class="ta-c cl-blan">Nueva Tarea</h2>
                    <label> Nombre</label><br>
                    <input type="text" name="nombre" class="tx" required="">
                    <label> Detalle</label><br>
                    <textarea name="detalle" class="txa" ></textarea>
                    <br>
                    <label> Fecha</label> <input type="date" name="fecha" class="fecha" required=""><br>
                    <div>
                        <label> Hora Inicio</label><input type="time" name="h-ini" class="h-ini" required=""><br>
                    </div>
                    <div>
                        <label> Hora Fin</label><input type="time" name="h-fin" class="h-fin"><br>
                    </div>


                    <h4 class="ta-c">Prioridad</h4>
                    <label> Normal</label><input type="radio" name="prioridad" value="A" checked="" class="r-a"><br>
                    <label> Importante</label><input type="radio" name="prioridad" value="B" class="r-b"><br>
                    <label> Urgente</label><input type="radio" name="prioridad" value="C" class="r-c"><br>
                    <br>
                    <div class="ta-c">
                        <button class="btn-agregar">Agregar Tarea</button>
                    </div>

                </form>
            </div>
        </div>
        <%
                break;
            case "editar":
                if (request.getParameter("id") != null) {
                    String id = request.getParameter("id");
                    rs = st.executeQuery("SELECT * FROM tareas WHERE id='" + id + "'");
                    rs.next();
                    String nombre = rs.getString("nombre");
                    String detalle = rs.getString("detalle");
                    String fecha = rs.getString("fecha");
                    String h_inicio = rs.getString("hora_inicio");
                    String h_fin = rs.getString("hora_fin");

        %>

        <div class="full">
            <div class="centrar">
                <a href="?op=eliminar&del_id=<%=id%>"class="eliminar">Eliinar</a>
                <a href="index.jsp"class="cerrar">Cerrar</a>
                <form method="POST" class="f-n-tarea">
                    <h2 class="ta-c cl-blan">Tarea</h2>
                    <label> Nombre</label><br>
                    <input type="hidden" name="act_id" class="tx" required="" value="<%=id%>">
                    <input type="text" name="act_nombre" class="tx" required="" value="<%=nombre%>">
                    <label> Detalle</label><br>
                    <textarea name="act_detalle" class="txa" ><%=detalle%></textarea>
                    <br>
                    <label> Fecha</label> <input type="date" name="act_fecha" class="fecha" required="" value="<%=fecha%>"><br>
                    <div>
                        <label> Hora Inicio</label><input type="time" name="act_h-ini" class="h-ini" required="" value="<%=h_inicio%>"><br>
                    </div>
                    <div>
                        <label> Hora Fin</label><input type="time" name="act_h-fin" class="h-fin" value="<%=h_fin%>"><br>
                    </div>

                    <h4 class="ta-c">Prioridad</h4>
                    <label> Normal</label><input type="radio" name="act_prioridad" value="A" checked="" class="r-a"><br>
                    <label> Importante</label><input type="radio" name="act_prioridad" value="B" class="r-b"><br>
                    <label> Urgente</label><input type="radio" name="act_prioridad" value="C" class="r-c"><br>
                    <br>
                    <div class="ta-c">
                        <button class="btn-agregar">Actualizar Tarea</button>
                    </div>

                </form>
            </div>
        </div>


        <%

                        }

                        break;

                    case "eliminar":
                        if (request.getParameter("del_id") != null) {
                            String id = request.getParameter("del_id");
                            st.executeUpdate("DELETE FROM tareas WHERE id='" + id + "'");
                            response.sendRedirect("index.jsp");
                        }

                        break;

                }
            }

            try {
                if (request.getParameter("act_nombre") != null && request.getParameter("act_fecha") != null && request.getParameter("act_h-ini") != null && request.getParameter("act_prioridad") != null) {
                    out.print("agregando desde web");
                    String id = request.getParameter("act_id");
                    String nombre = request.getParameter("act_nombre");
                    String detalle = request.getParameter("act_detalle");
                    String fecha = request.getParameter("act_fecha");

                    String h_ini = request.getParameter("act_h-ini");
                    String h_fin = request.getParameter("act_h-fin");
                    String prioridad = request.getParameter("act_prioridad");
                    st.executeUpdate("UPDATE tareas SET nombre='" + nombre + "', detalle='" + detalle + "', fecha='" + fecha + "', hora_inicio='" + h_ini + "', hora_fin='" + h_fin + "', prioridad='" + prioridad + "' WHERE id='" + id + "'");
                    response.sendRedirect("index.jsp");

                }
            } catch (SQLException e) {
                out.print("error aqui" + e);
            }

            try {
                if (request.getParameter("nombre") != null && request.getParameter("fecha") != null && request.getParameter("h-ini") != null && request.getParameter("prioridad") != null) {
                    out.print("agregando desde web");
                    String nombre = request.getParameter("nombre");
                    String detalle = request.getParameter("detalle");
                    String fecha = request.getParameter("fecha");

                    String h_ini = request.getParameter("h-ini");
                    String h_fin = request.getParameter("h-fin");
                    String prioridad = request.getParameter("prioridad");
                    st.executeUpdate("INSERT INTO tareas VALUES(NULL,'" + nombre + "','" + detalle + "','" + fecha + "','" + h_ini + "','" + h_fin + "','" + prioridad + "')");
                    response.sendRedirect("index.jsp");
                }
            } catch (SQLException e) {
                out.print("error aqui" + e);
            }

            con.close();

        %>
        <script src="agenda.js" type="text/javascript"></script>
    </body>
</html>
