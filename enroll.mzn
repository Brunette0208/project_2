% Parameters
int: n_students;
int: n_days;
int: n_classes;
int: n_groups;
int: n_time_units_in_hour;
int: exclusion = -1;

set of int: Student = 1..n_students;
set of int: Class = 1..n_classes;
set of int: Group = 1..n_groups;
set of int: Day = 1..n_days;
set of int: Time = 0..n_time_units_in_hour * 24;
set of int: WorkTime = 0..max(Time)*n_days;
set of int: Preference = exclusion..max([student_prefers[s,g] | s in Student, g in Group]);

array[Student] of 0..5: student_break_importance;
array[Student, Group] of int: student_prefers;

array[Class] of Time: class_duration;
array[Class] of int: class_size;

array[Group] of Class: group_class;
array[Group] of Time: group_start;
array[Group] of Day: group_day;
array[Group, Group] of bool: groups_conflicts;

% Decision Variables
array[Student, Class] of var Opt_Group: assigned_group;
set of int: Opt_Group = 0..n_groups;

% Helper Variables
array[Student, Day] of var Time: day_start;
array[Student, Day] of var Time: day_end;
array[Student, Day] of var Time: time_spent_in_uni;
array[Student, Day] of var Time: time_spent_learning;
array[Student] of var Time: time_spent_on_breaks;
array[Student] of var int: break_disappointment;
array[Student] of var int: preference_disappointment;
array[Student] of var int: total_disappointment;

% helper function
function var int: ceil_div(var int: x, var int: y) =
  x div y + ((x mod y) > 0);

% Constraints
constraint forall(s in Student, c in Class) (
    if exists (g in Group) (group_class[g] == c /\ student_prefers[s, g] != exclusion) then
        assigned_group[s, c] in {g | g in Group where group_class[g] == c /\ student_prefers[s, g] != exclusion}
    else
        assigned_group[s, c] = 0
    endif
);

% Ensure no bilocation (no student attends conflicting groups at the same time)
constraint forall(s in Student, g1 in Group, g2 in Group where g1 != g2 /\ group_day[g1] == group_day[g2] /\ groups_conflicts[g1, g2]) (
    assigned_group[s, group_class[g1]] != g1 \/ assigned_group[s, group_class[g2]] != g2
);

% VARIABLES FOR BREAK DISAPPOINTMENT %


constraint forall(s in Student, d in Day) (
    day_start[s, d] = 
        if exists(c in Class)(assigned_group[s, c] != 0 /\ group_day[assigned_group[s, c]] == d) then
            min([group_start[g] | g in Group where group_day[g] == d /\ assigned_group[s, group_class[g]] == g])
        else
            0
        endif
);

constraint forall(s in Student, d in Day) (
    day_end[s, d] = 
        if exists(c in Class)(assigned_group[s, c] != 0 /\ group_day[assigned_group[s, c]] == d) then
            max([group_start[g] + class_duration[group_class[g]] 
                | g in Group where group_day[g] == d /\ assigned_group[s, group_class[g]] == g])
        else
            0
        endif
);

% Total time spent at the university per day.
constraint forall(s in Student, d in Day) (
    time_spent_in_uni[s, d] = day_end[s, d] - day_start[s, d]
);

% Total time spent learning per day (sum of durations of assigned classes on that day).
constraint forall(s in Student, d in Day) (
    time_spent_learning[s, d] = 
        sum([class_duration[group_class[g]] 
            | g in Group where group_day[g] == d /\ assigned_group[s, group_class[g]] == g])
);

% Weekly wasted time: time at university minus learning time, summed over days.
constraint forall(s in Student) (
    time_spent_on_breaks[s] = 
        sum([time_spent_in_uni[s, d] - time_spent_learning[s, d] | d in Day])
);

% Break disappointment: the wasted time normalized to full hours.
constraint forall(s in Student) (
    break_disappointment[s] = 
        ceil_div(max(0, time_spent_on_breaks[s]), n_time_units_in_hour)
);

% Calculate preference disappointment
constraint forall(s in Student) (
    preference_disappointment[s] =
        sum([max(0, max([student_prefers[s, g] | g in Group where group_class[g] == c]) - student_prefers[s, assigned_group[s, c]])
             | c in Class where assigned_group[s, c] != 0])
);

% Calculate total disappointment
constraint forall(s in Student) (
    total_disappointment[s] = 
        ceil_div(student_break_importance[s] * break_disappointment[s] +
                (10 - student_break_importance[s]) * preference_disappointment[s], 10)
);

% Objective: Minimize the sum of squared total disappointments
var int: total_squared_disappointment = sum([total_disappointment[s] * total_disappointment[s] | s in Student]);

solve minimize total_squared_disappointment;

% Output the results
output [
    "assignment = ", show([{assigned_group[s, c] | c in Class where assigned_group[s, c] != 0} | s in Student]), ";\n",
    "total_break_disappointment = ", show(sum([break_disappointment[s] | s in Student])), ";\n",
    "total_preference_disappointment = ", show(sum([preference_disappointment[s] | s in Student])), ";\n",
    "objective = ", show(total_squared_disappointment), ";\n"
];
