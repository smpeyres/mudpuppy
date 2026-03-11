# 1D coupled reaction-diffusion:
# D_A * d^2A/dx^2 = 2 * k_A * A^2 + k_B * A * B
# D_B * d^2B/dx^2 = k_B * A * B
# Neumann BC at x=0: A'(0) = -J_0/D_A, B'(0) = 0
# Dirichlet BC at x=delta: A(delta) = 0, B(delta) = B_B

dom0Scale = 1.0
delta = 1.5e-6 # m
k_A = 1e6 # m^3/mol-s
k_B = 1e6 # m^3/mol-s
J_0 = 1e-2 # mol/m^2/s
D_A = 1e-9 # m^2/s
D_B = 1e-9 # m^2/s
B_B = 1 # mol/m^3

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 100
  xmax = ${delta}
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [A]
  []
  [B]
  []
[]

[Kernels]
  [A_diffusion]
    type = CoeffDiffusionLin
    variable = A
    position_units = ${dom0Scale}
  []
  [B_diffusion]
    type = CoeffDiffusionLin
    variable = B
    position_units = ${dom0Scale}
  []
[]

[Reactions]
  [decay]
    species = 'A B'
    reaction_coefficient_format = 'rate'
    use_log = false
    use_ad = true
    block = 0
    reactions = 'A + A -> C: ${k_A}
                 A + B -> C: ${k_B}' # C is untracked and only used to define the reaction
  []
[]

[Materials]
  [A_mat]
    type = ADHeavySpecies
    heavy_species_name = A
    heavy_species_mass = 6.64e-26 # unused but required
    heavy_species_charge = 0.0 # unused but required
    diffusivity = ${D_A}
    potential_units = V # unused but required
  []
  [B_mat]
    type = ADHeavySpecies
    heavy_species_name = B
    heavy_species_mass = 6.64e-26 # unused but required
    heavy_species_charge = 0.0 # unused but required
    diffusivity = ${D_B}
    potential_units = V # unused but required
  []
[]

[BCs]
  [left_A_flux]
    type = NeumannBC
    variable = A
    boundary = 'left'
    value = ${J_0} # outward normal is -x, so positive argument gives negative slope
  []
  [left_B_flux]
    type = NeumannBC
    variable = B
    boundary = 'left'
    value = 0
  []
  [right_A_zero]
    type = DirichletBC
    variable = A
    boundary = 'right'
    value = 0
  []
  [right_B_zero]
    type = DirichletBC
    variable = B
    boundary = 'right'
    value = ${B_B}
  []
[]

# Note: FEM handles Neumann-Neumann problems differently, and can often return the trivial solution.
# This is not the same as MATLAB bvp4c and similar.
# Work-around for now is to use zero Dirichlet BC at x=delta.
# Just make sure the domain is large enough and that the flux @ x = delta is small enough.

[Functions]
  [A_ic_func]
    type = ParsedFunction
    expression = '(3 * D_A / k_A)*(x + (6 * D_A^2 / (k_A * J_0))^(1/3))^(-2)'
    symbol_names = 'J_0 D_A k_A'
    symbol_values = '${J_0} ${D_A} ${k_A}'
  []
[]

# IC's are very important for nonlinear problems, even if steady-state!
[ICs]
  [A_ic]
    type = FunctionIC
    variable = A
    function = A_ic_func
  []
  [B_ic]
    type = ConstantIC
    variable = B
    value = ${B_B}
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -snes_linesearch_type'
  petsc_options_value = 'lu bt'
  nl_rel_tol = 1e-12
  nl_max_its = 50
[]

[Outputs]
  exodus = true
[]
