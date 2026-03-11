# 1D reaction-diffusion: D_A * d^2A/dx^2 = k_A * A
# Neumann BC at x=0: A'(0) = -J_0/D_A
# Dirichlet BC at x=delta: A(delta) = 0

dom0Scale = 1.0
delta = 1e-6 # m
k_A = 1e6 # 1/s
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

# Scalar variable standing in for A_bulk
[AuxVariables]
  [A_bulk]
    family = SCALAR
    order = FIRST
    initial_condition = 0
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
    reactions = 'A -> B: ${k_A}' # B is untracked and only used to define the reaction
  []
[]

[Materials]
  [A_diffusivity]
    type = ADGenericConstantMaterial
    prop_names = 'diffA'
    prop_values = '${D_A}'
  []
[]

[BCs]
  [left_flux]
    type = NeumannBC
    variable = A
    boundary = 'left'
    value = ${J_0} # outward normal is -x, so positive argument gives negative slope
  []
  [right_coupled]
    type = CoupledScalarDirichletBC
    variable = A
    boundary = 'right'
    coupled_scalar = A_bulk
  []
[]

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
    expression = '(J_0 / sqrt(D_A * k_A)) * exp(-sqrt(k_A / D_A) * x)'
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
