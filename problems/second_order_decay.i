# 1D reaction-diffusion: D_A * d^2A/dx^2 = 2 * k_A * A^2
# Neumann BC at x=0: A'(0) = -J_0/D_A
# Dirichlet BC at x=delta: A(delta) = 0

dom0Scale = 1.0
delta = 1.5e-6 # m
k_A = 1e6 # m^3/mol-s
J_0 = 1e-2 # mol/m^2/s
D_A = 1e-9 # m^2/s

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
[]

[Kernels]
  [A_diffusion]
    type = CoeffDiffusionLin
    variable = A
    position_units = ${dom0Scale}
  []
[]

[Reactions]
  [decay]
    species = 'A'
    reaction_coefficient_format = 'rate'
    use_log = false
    use_ad = true
    block = 0
    reactions = 'A + A -> B: ${k_A}' # B is untracked and only used to define the reaction
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
[]

[BCs]
  [left_flux]
    type = NeumannBC
    variable = A
    boundary = 'left'
    value = ${J_0} # outward normal is -x, so positive argument gives negative slope
  []
  [right_zero]
    type = DirichletBC
    variable = A
    boundary = 'right'
    value = 0
  []
[]

# Note: FEM handles Neumann-Neumann problems differently, and can often return the trivial solution.
# This is not the same as MATLAB bvp4c and similar.
# Work-around for now is to use zero Dirichlet BC at x=delta.
# Just make sure the domain is large enough and that the flux @ x = delta is small enough.

[AuxVariables]
  [A_analytical]
  []
[]

[AuxKernels]
  [A_analytical_kern]
    type = FunctionAux
    variable = A_analytical
    function = A_exact
  []
[]

[Functions]
  [A_exact]
    type = ParsedFunction
    expression = '(3 * D_A / k_A)*(x + (6 * D_A^2 / (k_A * J_0))^(1/3))^(-2)'
    symbol_names = 'J_0 D_A k_A'
    symbol_values = '${J_0} ${D_A} ${k_A}'
  []
[]

[Postprocessors]
  [L2_error]
    type = ElementL2Error
    variable = A
    function = A_exact
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
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  nl_rel_tol = 1e-12
[]

[Outputs]
  exodus = true
[]
