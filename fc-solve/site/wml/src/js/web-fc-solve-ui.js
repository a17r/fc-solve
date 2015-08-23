"use strict";
var entityMap = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': '&quot;',
    "'": '&#39;',
    "/": '&#x2F;'
};

function escapeHtml(string) {
    return String(string).replace(/[&<>"'\/]/g, function (s) {
        return entityMap[s];
    });
}

function _increment_move_indices(move_s) {
    return move_s.replace(/(stack|freecell)( )(\d+)/g,
        function (match, resource_s, sep_s, digit_s) {
            return (resource_s + sep_s +
                (1 + parseInt(digit_s))
            );
        }
    );
}

Class('FC_Solve_UI',
    {
        has: {
            _instance: { is: rw },
            _solve_err_code: { is: rw },
            _was_iterations_count_exceeded: { is: rw, init: false },
            _is_expanded: { is: rw, init: false },
            _expanded_pristine_output: { is: rw },
            _unexpanded_pristine_output: { is: rw },
            _is1based: { is: rw },
        },
        methods: {
            _calc_is_1_based: function() {
                var that = this;

                that._is1based = ($("#one_based").is(':checked') ? true : false);
            },
            _is_unicode_suits_checked: function() {
                return $("#unicode_suits").is(':checked');
            },
            _webui_output_set_text: function(text) {
                $("#output").val(text);

                return;
            },
            _one_based_process: function (text) {
                return text.replace(/^Move[^\n]+$/mg, _increment_move_indices);
            },
            _process_pristine_output: function(text) {
                var that = this;

                return (that._is1based
                    ? that._one_based_process(text)
                    : text
                );
            },
            _update_output: function () {
                var that = this;

                that._calc_is_1_based();

                that._webui_output_set_text(
                    that._process_pristine_output(that._calc_pristine_output())
                );

                if (that._solve_err_code == FCS_STATE_WAS_SOLVED ) {
                    var html = '';

                    html += "<ol>\n";
                    var seq = that._instance._proto_states_and_moves_seq;

                    var _render_state = function(s) {
                        return "<li class=\"state\"><pre>" + that._unicode_proc(s.str) + "</pre></li>\n\n";
                    };

                    var _out_state = function(i) {
                        html += _render_state(seq[i]);
                    };

                    _out_state(0);
                    for (var i = 1; i < seq.length - 1; i+=2) {
                        html += "<li id=\"move_" + i + "\" class=\"move unexpanded\"><span class=\"mega_move\">" + that._process_pristine_output(seq[i].m.str) + "</span>\n<button id=\"expand_move_" + i + "\" class=\"expand_move\">Expand Move</button>\n</li>\n";

                        _out_state(i+1);
                    }
                    $("#dynamic_output").html(html);

                    $("#dynamic_output").on("click", "button.expand_move", function (event) {
                        var button = $(this);
                        var b_id = button.attr('id');
                        var idx = parseInt(b_id.match(/^expand_move_([0-9]+)$/)[1]);

                        var move_ctl = $("#move_" + idx);
                        var calc_class = 'calced';
                        if (! move_ctl.hasClass(calc_class)) {
                            var inner_moves = that._instance._calc_expanded_move(idx);

                            var inner_html = '';

                            inner_html += "<ol class=\"inner_moves\">";

                            var _out_inner_move = function(i) {
                                inner_html += "<li class=\"move\"><span class=\"inner_move\">" + inner_moves[i].str + "</span>\n</li>\n";
                                return;
                            }
                            for (var i = 0; i < inner_moves.length-1 ; i += 2) {
                                _out_inner_move(i);
                                inner_html += _render_state(inner_moves[i+1]);
                            }
                            _out_inner_move(inner_moves.length-1);
                            inner_html += "</ol>";
                            move_ctl.append(
                                inner_html
                            );
                            move_ctl.toggleClass(calc_class);
                        }
                        move_ctl.toggleClass("expanded");
                        move_ctl.toggleClass("unexpanded");
                        button.text(move_ctl.hasClass("expanded") ? "Unexpand move" : "Expand move");
                    }
                    );
                }
                return;
            },

            _re_enable_output: function() {
                $("#output").removeAttr("disabled");

                return;
            },
            _webui_set_status_callback: function(myclass, mylabel) {
                var that = this;

                var ctl = $("#fc_solve_status");
                ctl.removeClass();
                ctl.addClass(myclass);
                ctl.html(escapeHtml(mylabel));

                var is_exceed = (myclass == "exceeded");

                if (is_exceed) {
                    that._was_iterations_count_exceeded = true;
                }

                if (is_exceed || (myclass == "impossible")) {
                    that._re_enable_output();
                }

                return;
            },
            _calc_pristine_output: function(buffer) {
                var that = this;

                if (that._solve_err_code == FCS_STATE_WAS_SOLVED ) {
                    if (that._is_expanded) {
                        if (! that._expanded_pristine_output) {
                            that._instance.display_expanded_moves_solution(
                                {
                                    output_cb: function(buffer) {
                                        that._expanded_pristine_output = buffer;
                                    }
                                }
                            );
                        }
                        return that._expanded_pristine_output;
                    }
                    else {
                        if (! that._unexpanded_pristine_output) {
                            that._instance.display_solution(
                                {
                                    output_cb: function(buffer) {
                                        that._unexpanded_pristine_output = buffer;
                                    }
                                }
                            );

                        }
                        return that._unexpanded_pristine_output;
                    }
                }
                else {
                    return "";
                }
            },
            _webui_set_output: function(buffer) {
                var that = this;

                that._re_enable_output();

                that._update_output();

                return;
            },
            _enqueue_resume: function () {
                var that = this;

                setTimeout(
                    function() { return that.do_resume(); },
                    50
                );

                return;
            },
            _handle_err_code: function() {
                var that = this;
                if (that._solve_err_code == FCS_STATE_WAS_SOLVED ) {
                    that._webui_set_output();
                } else if (that._solve_err_code == FCS_STATE_SUSPEND_PROCESS
                    && !that._was_iterations_count_exceeded) {
                    that._enqueue_resume();
                }

                return;
            },
            do_resume: function() {
                var that = this;

                that._solve_err_code = that._instance.resume_solution();

                that._handle_err_code();

                return;
            },
            _get_string_params: function() {
                var text = $("#string_params").val();
                return text.match(/\S/) ? text : null;
            },
            _get_cmd_line_preset: function() {
                return $("#preset").val();
            },
            _calc_initial_board_string: function() {
                return $("#stdin").val().replace(/#[^\r\n]*\r?\n?/g, '');
            },
            _disable_output_display: function() {
                $("#output").attr("disabled", true);

                return;
            },
            _unicode_proc: function(s) {
                var that = this;

                return that._instance.unicode_preprocess(s);
            },
            do_solve: function() {
                var that = this;

                that._expanded_pristine_output = null;
                that._unexpanded_pristine_output = null;

                that._disable_output_display();
                that._was_iterations_count_exceeded = false;

                that._instance = new FC_Solve({
                    cmd_line_preset: that._get_cmd_line_preset(),
                    set_status_callback: function(myclass, mylabel) {
                        return that._webui_set_status_callback(myclass, mylabel);
                    },
                    is_unicode_cards: that._is_unicode_suits_checked(),
                    dir_base: 'fcs_ui',
                    string_params: that._get_string_params(),
                });

                that._solve_err_code = that._instance.do_solve(
                    that._calc_initial_board_string()
                );

                that._handle_err_code();

                return;
            },
            toggle_expand: function() {
                var that = this;

                var ret = (that._is_expanded = ! that._is_expanded);

                that._webui_set_output();

                return ret;
            }
        },
    }
);


// Thanks to Stefan Petrea ( http://garage-coding.com/ ) for inspiring this
// feature.
var previous_deal_idx = 1;

function populate_input_with_numbered_deal() {

    var input_s = $('#deal_number').val();
    /*
    var new_idx = prompt("Enter MS Freecell deal number:");

    // Prompt returned null (user cancelled).
    if (! new_idx) {
        return;
    }

    previous_deal_idx = parseInt(new_idx);
    */

    if (! input_s.match(/^[1-9][0-9]*$/)) {
        alert("Wrong input - please enter a positive integer.");
        return;
    }

    previous_deal_idx = parseInt(input_s);

    $("#stdin").val(
        "# MS Freecell Deal #" + previous_deal_idx +
        "\n#\n" +
        deal_ms_fc_board(previous_deal_idx)
    );

    return;
}


Class('FC_Solve_Bookmarking', {
        has: {
            bookmark_controls: {
                is: ro,
            },
            show: {
                is: ro,
            },
        },
        methods: {
            _get_loc: function() {
                return window.location;
            },
            _get_base_url: function () {
                var that = this;

                var loc = that._get_loc();
                return loc.protocol + '//' + loc.host + loc.pathname;
            },
            _each_control: function(cb) {
                var that = this;

                that.bookmark_controls.forEach(cb);
            },
            on_bookmarking: function() {
                var that = this;

                var get_v = function(myid) {
                    var ctl = $('#' + myid);
                    return ctl.is(':checkbox') ?  (ctl.is(':checked') ? '1' : '0') : ctl.val();
                };

                var control_values = {};

                that._each_control(function (myid) {
                    control_values[myid] = get_v(myid);
                });

                var bookmark_string = that._get_base_url() + '?' + $.querystring(control_values);

                $("#fcs_bm_results_input").val(bookmark_string);

                var a_elem = $("#fcs_bm_results_a");
                // Too long to be effective.
                // a_elem.text(bookmark_string);
                a_elem.attr('href', bookmark_string);

                $("#fcs_bookmark_wrapper").removeClass("disabled");

                return;
            },
            restore_bookmark: function () {
                var that = this;

                var qs = that._get_loc().search;

                if (! qs.length) {
                    return;
                }

                // Remove trailing 1.
                var params = $.querystring(qs.substr(1));

                that._each_control(function (myid) {
                    var ctl = $('#' + myid);
                    if (ctl.is(':checkbox')) {
                        ctl.prop('checked', ((params[myid] == "1") ? true : false));
                    }
                    else {
                        ctl.val(params[myid]);
                    }
                });

                that.show.forEach(function (rec) {
                    var id = rec.id;
                    var deps = rec.deps;

                    var should_toggle = false;
                    deps.forEach(function (d) {
                        if ($("#" + d).val().length > 0) {
                            should_toggle = true;
                        }
                    });

                    if (should_toggle) {
                        if ($("#" + id).hasClass("disabled")) {
                            rec.callback();
                        }
                    }
                });

                return;
            },
        },
    }
);

function toggle_advanced() {
    var ctl = $("#fcs_advanced");
    ctl.toggleClass("disabled");

    var set_text = function (my_text) {
        $("#fcs_advanced_toggle").text(my_text);
    };

    set_text(
        ctl.hasClass("disabled") ? "Advanced ▼" : "Advanced ▲"
    );

    return;
}

function _create_bmark_obj() {
    return new FC_Solve_Bookmarking({ bookmark_controls: ['stdin', 'preset', 'deal_number', 'one_based', 'unicode_suits', 'string_params', ], show: [{ id: 'fcs_advanced', deps: ['string_params',], callback: toggle_advanced,}, ],});
}

function on_bookmarking() {
    return _create_bmark_obj().on_bookmarking();
}

function restore_bookmark() {
    return _create_bmark_obj().restore_bookmark();
}

var fcs_ui = new FC_Solve_UI();

function fc_solve_do_solve() {
    return fcs_ui.do_solve();
}

function on_toggle_one_based() {

    if ($("#output").val()) {
        fcs_ui._update_output();
    }

    return;
}

function clear_output() {
    return fcs_ui._webui_output_set_text('');
}

function toggle_expand_moves() {

    var is_expanded = fcs_ui.toggle_expand();

    $("#expand_moves_toggle").text(
        is_expanded ? "Unexpand Moves" : "Expand Moves"
    );
    return;
}
