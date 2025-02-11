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
array[Student, Class] of var Group: assigned_group;

% Helper Variables
array[Student, Day] of var Time: time_spent_at_university;
array[Student, Day] of var Time: wasted_time;
array[Student] of var Time: break_disappointment;
array[Student] of var int: preference_disappointment;
array[Student] of var int: total_disappointment;


% helper function
function var int: ceil_div(var int: x, var int: y) =
  x div y + ((x mod y) > 0);


% Constraints
constraint forall(s in Student, c in Class) (
    assigned_group[s, c] in {g | g in Group where group_class[g] == c}
);

% Ensure no bilocation (no student attends conflicting groups at the same time)
constraint forall(s in Student, g1 in Group, g2 in Group where g1 != g2 /\ group_day[g1] == group_day[g2] /\ groups_conflicts[g1, g2]) (
    assigned_group[s, group_class[g1]] != g1 \/ assigned_group[s, group_class[g2]] != g2
);

% Calculate time spent at university and wasted time
constraint forall(s in Student, d in Day) (
    time_spent_at_university[s, d] = 
        max([group_start[g] + class_duration[group_class[g]] | g in Group where group_day[g] == d /\ assigned_group[s, group_class[g]] == g]) -
        min([group_start[g] | g in Group where group_day[g] == d /\ assigned_group[s, group_class[g]] == g])
);

constraint forall(s in Student, d in Day) (
    wasted_time[s, d] = 
        max(0, time_spent_at_university[s, d] - 
            sum([class_duration[group_class[g]] | g in Group where group_day[g] == d /\ assigned_group[s, group_class[g]] == g]))
);

% Calculate break disappointment
constraint forall(s in Student) (
    break_disappointment[s] = 
        ceil_div(sum([wasted_time[s, d] | d in Day]), n_time_units_in_hour)
);

% Calculate preference disappointment
constraint forall(s in Student) (
    preference_disappointment[s] = 
        sum([student_prefers[s, g] - student_prefers[s, assigned_group[s, c]] | c in Class, g in Group where group_class[g] == c /\ student_prefers[s, g] > exclusion])
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
    "assignment = ", show([{assigned_group[s, c] | c in Class} | s in Student]), ";\n",
    "total_break_disappointment = ", show(sum([break_disappointment[s] | s in Student])), ";\n",
    "total_preference_disappointment = ", show(sum([preference_disappointment[s] | s in Student])), ";\n",
    "objective = ", show(total_squared_disappointment), ";\n"
];