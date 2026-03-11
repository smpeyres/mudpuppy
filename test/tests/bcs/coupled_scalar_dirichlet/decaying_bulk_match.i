# 1D diffusion with decaying bulk concentration
# dA/dt - D_A * d^2A/dx^2 = 0
# dA_bulk/dt = -k_A * A_bulk
# BCs: A(x=0,t) = 0, A(x=delta,t) = A_bulk(t)
# ICs: A_bulk(0) = A_0, A(x,0) = A_0*x/delta
#
# Analytical solution:
#   A_bulk(t) = A_0 * exp(-k_A * t)
#   A(x,t)    = A_bulk(t) * x / delta   (valid when D_A/delta^2 >> k_A)
#
# This test verifies that CoupledScalarDirichletBC correctly couples
# a scalar variable to a field variable boundary condition in a transient solve.

dom0Scale = 1.0
delta = 1e-6 # m
k_A = 1 # 1/s, must be much smaller than D_A/delta^2 for quasi-steady diffusion
A_0 = 1 # mol/m^3
D_A = 1e-9 # m^2/s

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 50
  xmax = ${delta}
[]

[Problem]
  type = FEProblem
[]

[Variables]
  [A]
  []
  [A_bulk]
    family = SCALAR
    order = FIRST
    initial_condition = ${A_0}
  []
[]

[ICs]
  [A_ic]
    type = FunctionIC
    variable = A
    function = '${A_0} * x / ${delta}'
  []
[]

[Kernels]
  [A_diffusion]
    type = CoeffDiffusionLin
    variable = A
    position_units = ${dom0Scale}
  []
  [A_time_derivative]
    type = TimeDerivative
    variable = A
  []
[]

[ScalarKernels]
  [dA_bulk_dt]
    type = ODETimeDerivative
    variable = A_bulk
  []
[]

[ChemicalReactions]
  [ScalarNetwork]
    species = 'A_bulk'
    use_log = false
    use_ad = true
    reactions = 'A_bulk -> B : ${k_A}'
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
  [left_zero]
    type = DirichletBC
    variable = A
    boundary = 'left'
    value = 0
  []
  [right_coupled]
    type = CoupledScalarDirichletBC
    variable = A
    boundary = 'right'
    coupled_scalar = A_bulk
  []
[]

[Functions]
  [A_bulk_exact]
    type = ParsedFunction
    expression = 'A_0 * exp(-k_A * t)'
    symbol_names = 'A_0 k_A'
    symbol_values = '${A_0} ${k_A}'
  []
  [A_exact]
    type = ParsedFunction
    expression = 'A_0 * exp(-k_A * t) * x / delta'
    symbol_names = 'A_0 k_A delta'
    symbol_values = '${A_0} ${k_A} ${delta}'
  []
[]

[Postprocessors]
  # Compare A_bulk scalar variable against analytical exponential decay
  [A_bulk_value]
    type = ScalarVariable
    variable = A_bulk
  []
  [A_bulk_analytical]
    type = FunctionValuePostprocessor
    function = A_bulk_exact
    point = '0 0 0'
  []
  [A_bulk_rel_error]
    type = RelativeDifferencePostprocessor
    value1 = A_bulk_value
    value2 = A_bulk_analytical
  []
  # Compare field variable against analytical solution
  [A_L2_error]
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
  type = Transient
  end_time = 5
  dt = 0.02
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -snes_linesearch_type'
  petsc_options_value = 'lu basic'
[]

[Outputs]
  exodus = true
  csv = true
[]
