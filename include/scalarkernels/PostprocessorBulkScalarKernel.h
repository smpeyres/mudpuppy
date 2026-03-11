//* This file is part of mudpuppy
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ScalarKernel.h"

/**
 * Adds a postprocessor value as a source/sink term in a scalar ODE.
 *
 * Contributes the residual:  r_i += pp_value
 *
 * This is useful for coupling spatially-integrated quantities (e.g.
 * boundary fluxes computed by SideDiffusiveFluxIntegral) into a
 * well-mixed bulk ODE.  The postprocessor should be executed on
 * 'linear nonlinear' to provide tight coupling within each Newton
 * iteration.
 */
class PostprocessorBulkScalarKernel : public ScalarKernel
{
public:
  static InputParameters validParams();

  PostprocessorBulkScalarKernel(const InputParameters & parameters);

protected:
  virtual void reinit() override;
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  /// The postprocessor value to add to the residual
  const PostprocessorValue & _pp_value;
};
