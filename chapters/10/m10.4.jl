using StatisticalRethinking
using StatsFuns #logistic() function
using Turing

Turing.setadbackend(:reverse_diff)

d = CSV.read(joinpath(dirname(Base.pathof(StatisticalRethinking)), "..", "data",
    "chimpanzees.csv"), delim=';')
size(d) # Should be 504x8

# pulled_left, actors, condition, prosoc_left
@model m10_4(y, actors, x₁, x₂) = begin
    # Number of unique actors in the data set
    N_actor = length(unique(actors))

    # Set an TArray for the priors/param
    α = TArray{Any}(undef, N_actor)

    # For each actor [1,..,7] set a prior
    for i ∈ 1:length(α)
        α[i] ~ Normal(0,10)
    end

    βp ~ Normal(0, 10)
    βpC ~ Normal(0, 10)

    for i ∈ 1:length(y)
        p = logistic(α[actors[i]] + (βp + βpC * x₁[i]) * x₂[i])
        y[i] ~ Binomial(1, p)
    end
end

posterior = sample(m10_4(d[:,:pulled_left], d[:,:actor],d[:,:condition],
    d[:,:prosoc_left]),
    Turing.NUTS(2500, 500, 0.95))
describe(posterior)
#              Mean           SD       Naive SE       MCSE         ESS
#  βpC   -0.181394034  0.28946513 0.0057893027 0.0266018473  118.404696
# α[1]   -0.750003835  0.29794860 0.0059589721 0.0278564821  114.401093
# α[2]    9.372324757  4.49534602 0.0899069204 0.8306772626   29.286104
# α[3]   -1.067303557  0.32767901 0.0065535802 0.0329610836   98.831248
# α[4]   -1.060339791  0.27627393 0.0055254786 0.0298318788   85.766681
# α[5]   -0.707040908  0.28169208 0.0056338417 0.0226231747  155.039440
# α[6]    0.218884973  0.27572737 0.0055145474 0.0312307275   77.946310
# α[7]    1.803365110  0.38459001 0.0076918002 0.0392945213   95.792607
#   βp    0.870271237  0.27987766 0.0055975532 0.0324186869   74.532489

# Rethinking
#       mean   sd  5.5% 94.5% n_eff Rhat
# a[1] -0.74 0.27 -1.17 -0.31  3838    1
# a[2] 11.02 5.53  4.46 21.27  1759    1
# a[3] -1.05 0.28 -1.50 -0.61  3784    1
# a[4] -1.05 0.27 -1.48 -0.62  3761    1
# a[5] -0.74 0.27 -1.18 -0.32  4347    1
# a[6]  0.21 0.27 -0.23  0.66  3932    1
# a[7]  1.81 0.39  1.19  2.46  4791    1
# bp    0.84 0.26  0.42  1.26  2586    1
# bpC  -0.13 0.30 -0.63  0.34  3508    1
