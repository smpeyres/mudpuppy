//* This file is part of mudpuppy
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADDiffusiveFluxScalarBC.h"
#include "MooseVariableScalar.h"

#include "libmesh/quadrature.h"

registerMooseObject("mudpuppyApp", ADDiffusiveFluxScalarBC);

InputParameters
ADDiffusiveFluxScalarBC::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addClassDescription("Computes the boundary integral of the diffusive flux, "
                             "scaling_factor * integral(-D * grad(C) . n dA), and contributes it "
                             "directly to a coupled scalar variable's residual and Jacobian. "
                             "This replaces the postprocessor-based coupling chain "
                             "(SideDiffusiveFluxIntegralLin + ScalePostprocessor + "
                             "PostprocessorBulkScalarKernel) and provides the correct AD Jacobian "
                             "for the dR_bulk/dC_field coupling block.");
  params.addRequiredCoupledVar("scalar_variable",
                               "Scalar variable whose residual receives the flux integral.");
  params.addParam<MaterialPropertyName>("diffusivity",
                                        "",
                                        "Name of the AD diffusivity material property. "
                                        "Defaults to 'diff' + variable_name (Zapdos convention).");
  params.addParam<Real>(
      "scaling_factor", 1.0, "Prefactor applied to the flux integral (e.g. -A/V).");
  return params;
}

ADDiffusiveFluxScalarBC::ADDiffusiveFluxScalarBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters),
    _diffusivity(getADMaterialProperty<Real>(
        isParamValid("diffusivity") && !getParam<MaterialPropertyName>("diffusivity").empty()
            ? std::string(getParam<MaterialPropertyName>("diffusivity"))
            : "diff" + _var.name())),
    _scalar_var(*getScalarVar("scalar_variable", 0)),
    _scaling_factor(getParam<Real>("scaling_factor"))
{
}

ADReal
ADDiffusiveFluxScalarBC::computeQpResidual()
{
  // Flux integrand at one QP; no test-function weighting because we integrate
  // into a scalar (zero-dimensional) DOF.
  return _scaling_factor * (-_diffusivity[_qp] * _grad_u[_qp] * _normals[_qp]);
}

void
ADDiffusiveFluxScalarBC::computeResidual()
{
  // Accumulate the boundary integral as a plain Real (derivatives discarded).
  Real integral = 0.0;
  precalculateResidual();
  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
    integral += _JxW[_qp] * _coord[_qp] * MetaPhysicL::raw_value(computeQpResidual());

  std::vector<Real> residuals = {integral};
  addResiduals(_assembly, residuals, _scalar_var.dofIndices(), _scalar_var.scalingFactor());
}

void
ADDiffusiveFluxScalarBC::computeResidualsForJacobian()
{
  // Accumulate with AD so that derivative information is preserved for Jacobian assembly.
  _scalar_residuals.assign(1, ADReal{0.0});
  precalculateResidual();
  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
  {
    const auto jxw_c =
        (_use_displaced_mesh ? _ad_JxW[_qp] * _ad_coord[_qp] : ADReal{_JxW[_qp] * _coord[_qp]});
    _scalar_residuals[0] += jxw_c * computeQpResidual();
  }
}

void
ADDiffusiveFluxScalarBC::computeResidualAndJacobian()
{
  computeResidualsForJacobian();
  addResidualsAndJacobian(
      _assembly, _scalar_residuals, _scalar_var.dofIndices(), _scalar_var.scalingFactor());
}

void
ADDiffusiveFluxScalarBC::computeJacobian()
{
  computeResidualsForJacobian();
  addJacobian(_assembly, _scalar_residuals, _scalar_var.dofIndices(), _scalar_var.scalingFactor());
}

void
ADDiffusiveFluxScalarBC::computeOffDiagJacobian(unsigned int jvar)
{
  // AD computes derivatives w.r.t. all DOFs at once; only trigger on the
  // primary variable to avoid redundant work.
  if (jvar == _var.number())
    computeJacobian();
}
