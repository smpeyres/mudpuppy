//* This file is part of mudpuppy
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADIntegratedBC.h"

/**
 * Computes the boundary integral of the diffusive flux,
 *
 *   R_bulk += scaling_factor * integral(-D * grad(C) . n dA)
 *
 * and assembles it directly into a coupled scalar variable's residual and
 * Jacobian rows.  This replaces the postprocessor-based approach
 * (SideDiffusiveFluxIntegralLin + ScalePostprocessor +
 * PostprocessorBulkScalarKernel) and provides a correct AD Jacobian for the
 * coupling block dR_bulk/dC_field.
 *
 * The object inherits from ADIntegratedBC so that it has access to _grad_u
 * (with AD derivatives), _normals, and the boundary QP loop.  Its primary
 * MOOSE variable is the field variable (C); the residual and Jacobian are
 * assembled into the scalar variable's DOF row rather than C's DOF rows.
 */
class ADDiffusiveFluxScalarBC : public ADIntegratedBC
{
public:
  static InputParameters validParams();

  ADDiffusiveFluxScalarBC(const InputParameters & parameters);

protected:
  /// Flux integrand at one quadrature point (no test-function weighting).
  ADReal computeQpResidual() override;

  /// Accumulate scalar integral and assemble into scalar variable residual.
  void computeResidual() override;

  /// Accumulate scalar integral with AD derivatives preserved.
  void computeResidualsForJacobian() override;

  /// Assemble residual + Jacobian into scalar variable DOF rows.
  void computeResidualAndJacobian() override;

  /// Assemble Jacobian into scalar variable DOF rows.
  void computeJacobian() override;

  /// AD computes all at once; only trigger on primary variable.
  void computeOffDiagJacobian(unsigned int jvar) override;

private:
  /// AD diffusivity material property (defaults to "diff" + variable_name).
  const ADMaterialProperty<Real> & _diffusivity;

  /// The scalar bulk variable whose residual/Jacobian we populate.
  const MooseVariableScalar & _scalar_var;

  /// Optional prefactor applied to the flux integral (e.g. -A/V).
  const Real _scaling_factor;

  /// Single-entry AD accumulator for the boundary integral.
  std::vector<ADReal> _scalar_residuals;
};
