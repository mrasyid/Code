/*=========================================================================
$Author: bjian $
$Date: 2010/02/24 04:51:29 $
$Revision: 1.1 $
=========================================================================*/

/**
 * \file gmmreg_grbf_func.cpp
 * \brief The implementation of the class gmmreg_grbf_func
 */

#include "gmmreg_grbf_func.h"
#include "gmmreg_utils.h"

double gmmreg_grbf_L2_func::eval(double& f1, double& f2,
    vnl_matrix<double>& g1, vnl_matrix<double>& g2) {
  /* L2 version */
  double f = f1 - 2*f2;
  gradient = g1*2 - g2*2;
  return f;
}

double gmmreg_grbf_KC_func::eval(double& f1, double& f2,
    vnl_matrix<double>& g1, vnl_matrix<double>& g2) {
  /* -KC^2 version */
  double f21 = f2/f1;
  double f =  -f2*f21;
  gradient = g1*2*f21*f21 - g2*2*f21;
  return f;
}

double gmmreg_grbf_func::f(const vnl_vector<double>& x) {
  gmmreg->perform_transform(x);
  double bending = gmmreg->bending_energy();
  double energy1 = GaussTransform(gmmreg->transformed_model,
      gmmreg->transformed_model, scale, gradient1);
  double energy2 = GaussTransform(gmmreg->transformed_model,
      gmmreg->scene, scale, gradient2);
  double energy = eval(energy1, energy2, gradient1, gradient2);
  energy += lambda * bending;
  return energy;
}

void gmmreg_grbf_func::gradf(const vnl_vector<double>& x,
    vnl_vector<double>& g) {
  gmmreg->compute_gradient(lambda,gradient, grad_all);
  int rows_x = grad_all.rows();
  int start_row = 0;
  for (int i = start_row, k = 0; i < rows_x; ++i) {
    for (int j = 0; j < d; ++j, ++k) {
      g[k] = grad_all(i, j);
    }
  }
}

void gmmreg_grbf_func::prepare_param_gradient() {
  gradient.set_size(m,d);
  grad_all.set_size(n,d);
}
