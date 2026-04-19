<!---Shifa Khan Delhi--->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib uri="http://www.springframework.org/tags/form" prefix="spring" %>
<%@ taglib prefix="custom" tagdir="/WEB-INF/tags" %>

<custom:commonElements />

<main id="main" class="main">

    <!-- ================= FORM ================= -->
    <spring:form id="dept_form" action="dept_mstAction" method="POST" modelAttribute="dept_CMD">

        <div class="container-fluid">
            <div class="card">

                <div class="card-header">
                    <h5>Department Master</h5>
                </div>

                <div class="card-body">
                    <div class="row g-3">

                        <!-- Department Name -->
                        <div class="col-md-3">
                            <label class="form-label">
                                <span class="text-danger">*</span> Department Name
                            </label>
                            <input type="text" class="form-control" name="dept_name" id="dept_name"
                                maxlength="200" />
                            <small id="deptMsg" style="color:red; display:none;">
                                Department already exists
                            </small>
                            <!-- IMPORTANT FOR UPDATE -->
                            <input type="hidden" name="old_dept_code" id="old_dept_code" />
                        </div>

                        <!-- Description -->
                        <div class="col-md-3">
                            <label class="form-label">
                                <span class="text-danger">*</span> Description
                            </label>
                            <textarea class="form-control" name="dept_desc" id="dept_desc"
                                rows="3"></textarea>
                        </div>

                        <!-- Status -->
                        <div class="col-md-3">
                            <label class="form-label">
                                <span class="text-danger">*</span> Status
                            </label>
                            <select class="form-select" id="softdeleteFlag" name="softdeleteFlag">
                                <option value="0">--Select--</option>
                                <option value="N">Active</option>
                                <option value="Y">Inactive</option>
                            </select>
                        </div>

                    </div>
                </div>

                <div class="card-footer text-center">
                    <button type="button" class="btn btn-outline-danger" id="clearBtn">Clear</button>
                    <button type="button" class="btn btn-outline-success" id="saveBtn">Save</button>
                </div>

            </div>
        </div>
    </spring:form>

    <!-- ================= TABLE ================= -->
    <div class="container-fluid mt-3">
        <div class="card">
            <div class="card-body">

                <table id="deptReport" class="table table-bordered table-hover">
                    <thead>
                        <tr>
                            <th>Sr No</th>
                            <th>Department Name</th>
                            <th>Description</th>
                            <th>Status</th>
                            <th class="text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>

            </div>
        </div>
    </div>

</main>

<%-- <spring:form action="delete_dept" method="post" id="deleteForm">
    <input type="hidden" name="dept_code" id="deleteId">
</spring:form> --%>

<script nonce="${cspNonce}">

    let table;
    let isClearing = false;

    $(document).ready(function () {

        // ================= DATATABLE =================
        table = $('#deptReport').DataTable({
            processing: true,
            serverSide: true,
            pageLength: 10,
            lengthMenu: [[10, 25, 50, 100], [10, 25, 50, 100]],
            scrollY: "400px",
            scrollX: true,
            ajax: function (data, callback, settings) {

                var startPage   = data.start;
                var pageLength  = data.length;
                var Search      = data.search.value;
                var orderColunm = data.order[0].column + 1;
                var orderType   = data.order[0].dir;

                $.ajax({
                    url: 'getDeptdataUrl',
                    type: 'POST',
                    data: {
                        startPage:   startPage,
                        pageLength:  pageLength,
                        Search:      Search,
                        orderColunm: orderColunm,
                        orderType:   orderType
                    },
                    success: function (list) {

                        $.ajax({
                            url: 'getDeptdataCountUrl',
                            type: 'POST',
                            data: {
                                startPage:   startPage,
                                pageLength:  pageLength,
                                Search:      Search,
                                orderColunm: orderColunm,
                                orderType:   orderType
                            },
                            success: function (count) {

                                var jsondata = [];

                                for (var i = 0; i < list.length; i++) {

                                    var srNo = startPage + i + 1;

                                    // Status Badge
                                    var statusLabel = list[i].softdeleteFlag === 'N'
                                        ? "<span class='badge bg-success'>Active</span>"
                                        : "<span class='badge bg-danger'>Inactive</span>";

                                    // Edit Button
                                    var actionBtn =
                                        "<button type='button' class='btn btn-outline-primary btn-sm sharp editBtn' " +
                                        "data-id='"     + list[i].dept_code      + "' " +
                                        "data-name='"   + list[i].dept_name      + "' " +
                                        "data-desc='"   + list[i].dept_desc      + "' " +
                                        "data-status='" + list[i].softdeleteFlag + "'>" +
                                        "<i class='fa fa-pencil edtcls'></i>" +
                                        "</button>";

                                    jsondata.push([
                                        srNo,
                                        list[i].dept_name,
                                        list[i].dept_desc,
                                        statusLabel,
                                        actionBtn
                                    ]);
                                }

                                callback({
                                    draw:            data.draw,
                                    recordsTotal:    count,
                                    recordsFiltered: count,
                                    data:            jsondata
                                });
                            }
                        });
                    }
                });
            }
        });

        // ================= DUPLICATE NAME CHECK =================
        $("#dept_name").on("input", function () {
            if (isClearing) return;

            var deptName = $(this).val().trim();

            if (deptName.length === 0) {
                $("#deptMsg").hide();
                $("#saveBtn").prop("disabled", false);
                return;
            }

            $.ajax({
                url: 'checkDeptExists',
                type: 'POST',
                data: {
                    dept_name:     deptName,
                    old_dept_code: $("#old_dept_code").val()
                },
                success: function (response) {
                    if (response === "EXISTS") {
                        $("#deptMsg").show();
                        $("#saveBtn").prop("disabled", true);
                    } else {
                        $("#deptMsg").hide();
                        $("#saveBtn").prop("disabled", false);
                    }
                }
            });
        });

        // ================= SAVE / UPDATE =================
        $("#saveBtn").click(function () {

            if ($("#deptMsg").is(":visible")) {
                alert("Duplicate department not allowed");
                return;
            }

            var deptName   = $("#dept_name").val().trim();
            var deptDesc   = $("#dept_desc").val().trim();
            var statusFlag = $("#softdeleteFlag").val();

            if (deptName === "") {
                alert("Please Enter Department Name");
                return;
            }

            if (deptDesc === "") {
                alert("Please Enter Description");
                return;
            }

            var specialCharPattern = /^[a-zA-Z0-9\s]+$/;
            if (!specialCharPattern.test(deptDesc)) {
                alert("Description should not contain special characters");
                return;
            }

            if (statusFlag === "0") {
                alert("Please Select Status");
                return;
            }

            var form_data = new FormData(document.getElementById("dept_form"));

            $.ajax({
                url: 'dept_mstAction',
                type: "POST",
                data: form_data,
                processData: false,
                contentType: false,
                success: function (res) {
                    alert(res);
                    table.ajax.reload(null, false);
                    resetForm();
                }
            });
        });

        // ================= CLEAR =================
        $("#clearBtn").click(function () {
            if (confirm("Are you sure you want to clear this form?")) {
                resetForm();
            }
        });

        // ================= EDIT =================
        $(document).on("click", ".editBtn", function () {
            if (confirm("Are you sure you want to edit this record?")) {
                $("#old_dept_code").val($(this).data("id"));
                $("#dept_name").val($(this).data("name"));
                $("#dept_desc").val($(this).data("desc"));
                $("#softdeleteFlag").val($(this).data("status"));  // pre-fill status
                $("#deptMsg").hide();
                $("#saveBtn").prop("disabled", false);
                $("#saveBtn").text("Update");
                window.scrollTo({ top: 0, behavior: 'smooth' });
            }
        });

        // ================= RESET HELPER =================
        function resetForm() {
            isClearing = true;
            $("#dept_form")[0].reset();
            $("#old_dept_code").val("");
            $("#softdeleteFlag").val("0");  // reset dropdown to --Select--
            $("#deptMsg").hide();
            $("#saveBtn").prop("disabled", false);
            $("#saveBtn").text("Save");
            setTimeout(function () {
                isClearing = false;
            }, 300);
        }

    });
</script> 