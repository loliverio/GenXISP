using DataFrames
using CSV
using YAML
using GraphRecipes
using Plots
using PlotlyJS
using VegaLite
using StatsPlots


# Phase 1
results_p3 = joinpath("results", "results_p3","power.csv")
power = CSV.read(results_p3, DataFrame, missingstring="NA")
tstart = 3
tend = 400
names_power = ["Coal","gas_com","gas_open","Diesel","Bio","Solar","Wind","P_Hydro","Battery","NP_hydro"]

power_tot = DataFrame([power[:, 12]+power[:, 13]+power[:,14]+power[:, 15]+power[:, 16]+power[:, 17]+power[:, 18]+power[:, 19]+power[:, 20]+power[:, 21]+power[:, 22]+power[:, 23] power[:,24]+power[:, 25]+power[:, 26]+power[:, 27]+power[:, 28]+power[:, 29]+power[:, 30]+power[:, 31]+power[:, 32]+power[:, 33] power[:,34]+power[:, 35]+power[:, 36]+power[:, 37]+power[:, 38]+power[:, 39]+power[:, 40]+power[:, 41]+power[:, 42]+power[:, 43] power[:, 54]+power[:, 55]+power[:, 56] power[:,44]+power[:, 45]+power[:, 46]+power[:, 47]+power[:, 48]+power[:, 49]+power[:, 50]+power[:, 51]+power[:, 52]+power[:, 53] power[:,57]+power[:, 58]+power[:, 59]+power[:, 60]+power[:, 61]+power[:, 62]+power[:, 63]+power[:, 64]+power[:, 65]+power[:, 66]+power[:,67]+power[:, 68]+power[:, 69]+power[:, 70]+power[:, 71]+power[:, 72]+power[:, 73]+power[:,74]+power[:,75] power[:, 76]+power[:,77]+power[:, 78]+power[:, 79]+power[:, 80]+power[:, 81]+power[:, 82]+power[:, 83]+power[:,84]+power[:, 85]+power[:, 86]+power[:,87]+power[:, 88]+power[:, 89]+power[:, 90]+power[:, 91]+power[:, 92]+power[:, 93]+power[:,94]+power[:,95]+power[:, 96]+power[:,97]+power[:,98] power[:, 109]+power[:,110]+power[:, 111]+power[:, 112]+power[:, 113]+power[:, 114]+power[:, 115]+power[:, 116]+power[:,117]+power[:, 118]+power[:, 119]+power[:,120]+power[:, 121] power[:, 99]+power[:, 100]+power[:,101]+power[:, 102]+power[:, 103]+power[:, 104]+power[:, 105]+power[:, 106]+power[:, 107]+power[:, 108] power[:, 2]+power[:,3]+power[:, 4]+power[:, 5]+power[:, 6]+power[:, 7]+power[:, 8]+power[:, 9]+power[:,10]+power[:,11]],
    ["Coal","gas_com","gas_open","Diesel","Bio","Solar","Wind","P_Hydro","Battery","NP_hydro"])
    power_plot = DataFrame([collect(1:length(power_tot[tstart:tend,1])) power_tot[tstart:tend,1] repeat([names_power[1]],length(power_tot[tstart:tend,1]))],
    ["Hour","MW", "Resource_Type"]);
# as i have 8 resources so i have to run loop for 8 times.......... if you have more please change it 
for i in range(2,10)
    power_plot_temp = DataFrame([collect(1:length(power_tot[tstart:tend,i])) power_tot[tstart:tend,i] repeat([names_power[i]],length(power_tot[tstart:tend,i]))],["Hour","MW", "Resource_Type"])
    global power_plot = [power_plot; power_plot_temp]
end

# Adding charge profile as negative values
results_b = joinpath("results", "results_p3", "charge.csv")
charge = CSV.read(results_b, DataFrame, missingstring="NA")
charge_profile = -charge[tstart:tend, "Total"] # Making the values negative

charge_plot = DataFrame([collect(1:length(charge_profile)) charge_profile repeat(["Battery_PHS_Charging"], length(charge_profile))], ["Hour", "MW", "Resource_Type"])
power_plot = [power_plot; charge_plot]

case = joinpath("inputs","inputs_p3","TDR_results","Demand_data.csv")
loads = CSV.read(case, DataFrame, missingstring="NA")
loads_tot = loads[!,"Demand_MW_z1"] + loads[!,"Demand_MW_z2"] + loads[!,"Demand_MW_z3"] + loads[!,"Demand_MW_z4"] + loads[!,"Demand_MW_z5"] + loads[!,"Demand_MW_z6"] + loads[!,"Demand_MW_z7"] + loads[!,"Demand_MW_z8"] + loads[!,"Demand_MW_z9"] + loads[!,"Demand_MW_z10"]

tstart_demand = 1
tend_demand = 398
power_plot[!,"Demand_Total"] = repeat(loads_tot[tstart_demand:tend_demand], 11); # Adjusted for 9 resource types including Charge..... if you have more change this number


power_plot  |>
@vlplot() +
@vlplot(layer=[
    {mark={:area},
     encoding={
        x={:Hour, title="Time Step (hours)", labels="Resource_Type:n", axis={values=0:50:400}},
        y={:MW, title="Load (MW)", type="quantitative"},
        color={:Resource_Type, scale={scheme="category20"}, sort="descending"},
        order={field="Resource_Type:n"}
    }},
    {mark={:line, color="black", strokeDash=[0,0], strokeWidth=3},
     encoding={
        x={:Hour},
        y={:Demand_Total},
        color={value="black"},
        tooltip={field="Demand_Total"}
    }}
],
width=845, height=400,
title="Resource Capacity per Hour with Load Demand Curve, all Zones") +
@vlplot(mark={:line, color="black", strokeDash=[0,0], strokeWidth=3},
     encoding={
        x={:Hour},
        y={:Demand_Total},
        color={datum="Demand"},
        tooltip={field="Demand_Total"}
    })

