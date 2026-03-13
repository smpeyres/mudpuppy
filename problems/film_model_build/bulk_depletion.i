# Bulk depletion test: diffusion-coupled well-mixed reservoir
#
# Physics:
#   Film domain x in [0, delta]:
#     dC/dt = D * d^2C/dx^2
#   Bulk scalar ODE:
#     V * dC_bulk/dt = A * J(x=delta)   where J = -D * dC/dx (Fick's law)
#
#   BCs: C(0,t) = C_0 (fixed),  C(delta,t) = C_bulk(t) (coupled)
#   ICs: C_bulk(0) = C_bulk_0,  C(x,0) = C_0 + (C_bulk_0 - C_0)*x/delta
#
# Expected steady state: C_bulk -> C_0, C(x) -> C_0 (uniform)
#
# Quasi-steady analytical approximation (valid when D/delta^2 >> AD/(V*delta)):
#   C_bulk(t) ~ C_0 + (C_bulk_0 - C_0) * exp(-AD/(V*delta) * t)
#
# Sign convention for PostprocessorSinkScalarKernel:
#   The scalar kernel adds pp_value to the residual:
#     r = dC_bulk/dt + pp_value = 0  =>  dC_bulk/dt = -pp_value
#   We need: dC_bulk/dt = (A/V) * SideDiffusiveFluxIntegral
#   where SideDiffusiveFluxIntegral = -D * grad(C) . n_hat
#   Therefore: pp_value = -(A/V) * SideDiffusiveFluxIntegral
#   i.e. scaling_factor = -A/V

delta = 1e-4 # m, film thickness
D_C = 1e-9 # m^2/s, diffusivity
C_0 = 0.1 # mol/m^3, fixed boundary concentration
C_bulk_0 = 1.0 # mol/m^3, initial bulk concentration
A_cross = 1e-4 # m^2, interfacial area
V_bulk = 1e-6 # m^3, bulk volume
dom0Scale = 1.0 # scaling factor for position units

# Derived: time constant = V*delta/(A*D) = 1e-6 * 1e-4 / (1e-4 * 1e-9) = 1000 s
# So we run for ~5 time constants = 5000 s

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
  [C]
  []
  [C_bulk]
    family = SCALAR
    order = FIRST
    initial_condition = ${C_bulk_0}
  []
[]

[ICs]
  [C_ic]
    type = FunctionIC
    variable = C
    function = '${C_0} + (${C_bulk_0} - ${C_0}) * x / ${delta}'
  []
[]

[Kernels]
  [C_time]
    type = TimeDerivative
    variable = C
  []
  [C_diffusion]
    type = CoeffDiffusionLin
    variable = C
    position_units = ${dom0Scale}
  []
[]

[ScalarKernels]
  [C_bulk_time]
    type = ODETimeDerivative
    variable = C_bulk
  []
[]

[Materials]
  [C_diffusivity]
    type = ADGenericConstantMaterial
    prop_names = 'diffC'
    prop_values = '${D_C}'
  []
[]

[BCs]
  [left_fixed]
    type = DirichletBC
    variable = C
    boundary = 'left'
    value = ${C_0}
  []
  [right_coupled]
    type = CoupledScalarDirichletBC
    variable = C
    boundary = 'right'
    coupled_scalar = C_bulk
  []
  [C_bulk_flux]
    type = ADDiffusiveFluxScalarBC
    variable = C
    scalar_variable = C_bulk
    boundary = 'right'
    diffusivity = 'diffC'
    scaling_factor = '${fparse -A_cross / V_bulk}'
  []
[]

[Postprocessors]
  # Compute integral of diffusive flux on right boundary:
  #   SideDiffusiveFluxIntegral = integral of (-D * grad(C) . n_hat) dA
  # For 1D with unit cross section, this is -D * dC/dx at x=delta
  [boundary_flux]
    type = SideDiffusiveFluxIntegralLin
    variable = C
    boundary = 'right'
    execute_on = 'initial nonlinear linear timestep_end'
  []
  # Scale by -A/V for the scalar kernel
  [scaled_boundary_flux]
    type = ScalePostprocessor
    value = boundary_flux
    scaling_factor = '${fparse -A_cross / V_bulk}'
    execute_on = 'initial nonlinear linear timestep_end'
  []
  # Track C_bulk value
  [C_bulk_value]
    type = ScalarVariable
    variable = C_bulk
    execute_on = 'initial timestep_end'
  []
  # Analytical quasi-steady approximation
  [C_bulk_analytical]
    type = FunctionValuePostprocessor
    function = C_bulk_exact
    point = '0 0 0'
    execute_on = 'initial timestep_end'
  []
  # Relative error
  [C_bulk_rel_error]
    type = RelativeDifferencePostprocessor
    value1 = C_bulk_value
    value2 = C_bulk_analytical
    execute_on = 'initial timestep_end'
  []
[]

[Functions]
  [C_bulk_exact]
    type = ParsedFunction
    expression = 'C_0 + (C_bulk_0 - C_0) * exp(-A * D / (V * delta) * t)'
    symbol_names = 'C_0 C_bulk_0 A D V delta'
    symbol_values = '${C_0} ${C_bulk_0} ${A_cross} ${D_C} ${V_bulk} ${delta}'
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
  end_time = 5000
  dt = 10
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-12
[]

[Outputs]
  exodus = true
  csv = true
[]
