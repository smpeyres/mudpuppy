//* This file is part of mudpuppy
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "SideIntegralVariablePostprocessor.h"

/**
 * Computes the integral of the diffusive flux over a boundary:
 *
 *   integral of  -D * grad(C) . n_hat  dA
 *
 * where D is obtained from an AD material property on the adjacent
 * element (no separate boundary material declaration required).
 *
 * The material property name defaults to "diff" + variable_name,
 * following the Zapdos convention, but can be overridden.
 */
class SideDiffusiveFluxIntegralLin : public SideIntegralVariablePostprocessor
{
public:
  static InputParameters validParams();

  SideDiffusiveFluxIntegralLin(const InputParameters & parameters);

protected:
  virtual Real computeQpIntegral() override;

  /// Diffusivity material property (AD, pulled from element interior)
  const ADMaterialProperty<Real> & _diffusivity;
};
