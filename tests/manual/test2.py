#!/usr/bin/env python3
"""
Chi-squared fitting functions and utilities.
"""

from typing import Any, Callable, Dict, Optional, Tuple

import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import curve_fit


def chi_squared(
    y_observed: np.ndarray,
    y_expected: np.ndarray,
    uncertainties: Optional[np.ndarray] = None,
) -> float:
    """
    Calculate chi-squared statistic.

    Parameters:
    -----------
    y_observed : np.ndarray
        Observed data values
    y_expected : np.ndarray
        Expected/predicted values from model
    uncertainties : np.ndarray, optional
        Uncertainties (standard deviations) for each data point.
        If None, assumes equal weights (uncertainties = 1)

    Returns:
    --------
    float
        Chi-squared value
    """
    if uncertainties is None:
        uncertainties = np.ones_like(y_observed)

    residuals = y_observed - y_expected
    chi2 = np.sum((residuals / uncertainties) ** 2)
    return chi2


def reduced_chi_squared(
    chi2: float, n_data_points: int, n_parameters: int
) -> float:
    """
    Calculate reduced chi-squared (chi2 / degrees of freedom).

    Parameters:
    -----------
    chi2 : float
        Chi-squared value
    n_data_points : int
        Number of data points
    n_parameters : int
        Number of fitted parameters

    Returns:
    --------
    float
        Reduced chi-squared value
    """
    dof = n_data_points - n_parameters
    if dof <= 0:
        raise ValueError("Degrees of freedom must be positive")
    return chi2 / dof


def chi2_fit(
    func: Callable,
    x_data: np.ndarray,
    y_data: np.ndarray,
    uncertainties: Optional[np.ndarray] = None,
    initial_guess: Optional[np.ndarray] = None,
    bounds: Optional[Tuple] = None,
    method: str = "lm",
) -> Dict[str, Any]:
    """
    Perform chi-squared fitting of a function to data.

    Parameters:
    -----------
    func : Callable
        Function to fit. Should take x as first argument and parameters as
        subsequent arguments
    x_data : np.ndarray
        Independent variable data
    y_data : np.ndarray
        Dependent variable data
    uncertainties : np.ndarray, optional
        Uncertainties (standard deviations) for y_data. If None, assumes equal
        weights
    initial_guess : np.ndarray, optional
        Initial guess for parameters
    bounds : tuple, optional
        Bounds for parameters (lower_bounds, upper_bounds)
    method : str, default 'lm'
        Optimization method ('lm' for Levenberg-Marquardt, 'trf', 'dogbox')

    Returns:
    --------
    dict
        Dictionary containing:
        - 'params': fitted parameters
        - 'param_errors': parameter uncertainties
        - 'covariance': covariance matrix
        - 'chi2': chi-squared value
        - 'reduced_chi2': reduced chi-squared
        - 'dof': degrees of freedom
        - 'success': whether fit converged
    """
    try:
        # Use scipy.optimize.curve_fit for the fitting
        if uncertainties is not None:
            sigma = uncertainties
        else:
            sigma = None

        popt, pcov = curve_fit(
            func,
            x_data,
            y_data,
            sigma=sigma,
            p0=initial_guess,
            bounds=bounds if bounds else (-np.inf, np.inf),
            method=method,
            absolute_sigma=True,
        )

        # Calculate chi-squared
        y_fit = func(x_data, *popt)
        chi2 = chi_squared(y_data, y_fit, uncertainties)

        # Calculate parameter uncertainties
        param_errors = np.sqrt(np.diag(pcov))

        # Degrees of freedom
        dof = len(y_data) - len(popt)
        reduced_chi2 = reduced_chi_squared(chi2, len(y_data), len(popt))

        return {
            "params": popt,
            "param_errors": param_errors,
            "covariance": pcov,
            "chi2": chi2,
            "reduced_chi2": reduced_chi2,
            "dof": dof,
            "success": True,
            "y_fit": y_fit,
        }

    except Exception as e:
        return {
            "params": None,
            "param_errors": None,
            "covariance": None,
            "chi2": np.inf,
            "reduced_chi2": np.inf,
            "dof": 0,
            "success": False,
            "error": str(e),
            "y_fit": None,
        }


def plot_fit_results(
    x_data: np.ndarray,
    y_data: np.ndarray,
    fit_result: Dict[str, Any],
    func: Callable,
    uncertainties: Optional[np.ndarray] = None,
    title: str = "Chi-squared Fit Results",
    x_label: str = "x",
    y_label: str = "y",
) -> None:
    """
    Plot the data and fitted function.

    Parameters:
    -----------
    x_data : np.ndarray
        Independent variable data
    y_data : np.ndarray
        Dependent variable data
    fit_result : dict
        Result from chi2_fit function
    func : Callable
        Fitted function
    uncertainties : np.ndarray, optional
        Uncertainties for y_data
    title : str
        Plot title
    x_label : str
        X-axis label
    y_label : str
        Y-axis label
    """
    fig, (ax1, ax2) = plt.subplots(
        2, 1, figsize=(10, 8), gridspec_kw={"height_ratios": [3, 1]}
    )

    # Main plot
    if uncertainties is not None:
        ax1.errorbar(
            x_data,
            y_data,
            yerr=uncertainties,
            fmt="o",
            label="Data",
            capsize=3,
            alpha=0.7,
        )
    else:
        ax1.plot(x_data, y_data, "o", label="Data", alpha=0.7)

    if fit_result["success"]:
        x_smooth = np.linspace(x_data.min(), x_data.max(), 1000)
        y_smooth = func(x_smooth, *fit_result["params"])
        ax1.plot(x_smooth, y_smooth, "r-", label="Fit", linewidth=2)

        # Add fit statistics to plot
        stats_text = f"χ² = {fit_result['chi2']:.3f}\n"
        stats_text += f"χ²/ν = {fit_result['reduced_chi2']:.3f}\n"
        stats_text += f"DoF = {fit_result['dof']}"
        ax1.text(
            0.05,
            0.95,
            stats_text,
            transform=ax1.transAxes,
            verticalalignment="top",
            bbox=dict(boxstyle="round", facecolor="white", alpha=0.8),
        )

    ax1.set_xlabel(x_label)
    ax1.set_ylabel(y_label)
    ax1.set_title(title)
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Residuals plot
    if fit_result["success"]:
        residuals = y_data - fit_result["y_fit"]
        if uncertainties is not None:
            ax2.errorbar(
                x_data,
                residuals,
                yerr=uncertainties,
                fmt="o",
                capsize=3,
                alpha=0.7,
            )
        else:
            ax2.plot(x_data, residuals, "o", alpha=0.7)
        ax2.axhline(y=0, color="r", linestyle="--", alpha=0.5)
        ax2.set_xlabel(x_label)
        ax2.set_ylabel("Residuals")
        ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.show()


# Example usage and test functions
def linear_function(x, a, b):
    """Linear function: y = ax + b"""
    return a * x + b


def gaussian_function(x, amplitude, mean, sigma):
    """Gaussian function"""
    return amplitude * np.exp(-0.5 * ((x - mean) / sigma) ** 2)


def exponential_function(x, a, b, c):
    """Exponential function: y = a * exp(b * x) + c"""
    return a * np.exp(b * x) + c


def test_linear_fit():
    """Test chi-squared fitting with linear function"""
    # Generate synthetic data
    x = np.linspace(0, 10, 50)
    true_a, true_b = 2.5, 1.3
    y_true = linear_function(x, true_a, true_b)

    # Add noise
    np.random.seed(42)
    noise = np.random.normal(0, 0.5, len(x))
    y_data = y_true + noise
    uncertainties = np.full_like(y_data, 0.5)

    # Perform fit
    result = chi2_fit(
        linear_function, x, y_data, uncertainties, initial_guess=[2.0, 1.0]
    )

    print("Linear Fit Results:")
    print(f"True parameters: a={true_a}, b={true_b}")
    print(
        f"Fitted parameters: "
        f"a={result['params'][0]:.3f}±{result['param_errors'][0]:.3f}, "
        f"b={result['params'][1]:.3f}±{result['param_errors'][1]:.3f}"
    )
    print(f"Chi-squared: {result['chi2']:.3f}")
    print(f"Reduced chi-squared: {result['reduced_chi2']:.3f}")
    print(f"Degrees of freedom: {result['dof']}")
    print()

    # Plot results
    plot_fit_results(
        x,
        y_data,
        result,
        linear_function,
        uncertainties,
        title="Linear Function Fit",
        x_label="x",
        y_label="y",
    )

    return result


def test_gaussian_fit():
    """Test chi-squared fitting with Gaussian function"""
    # Generate synthetic data
    x = np.linspace(-5, 5, 100)
    true_amp, true_mean, true_sigma = 10.0, 0.5, 1.2
    y_true = gaussian_function(x, true_amp, true_mean, true_sigma)

    # Add noise
    np.random.seed(123)
    noise = np.random.normal(0, 0.3, len(x))
    y_data = y_true + noise
    uncertainties = np.full_like(y_data, 0.3)

    # Perform fit
    result = chi2_fit(
        gaussian_function,
        x,
        y_data,
        uncertainties,
        initial_guess=[8.0, 0.0, 1.0],
    )

    print("Gaussian Fit Results:")
    print(
        f"True parameters: amp={true_amp}, "
        f"mean={true_mean}, sigma={true_sigma}"
    )
    if result["success"]:
        print(
            f"Fitted parameters: "
            f"amp={result['params'][0]:.3f}±{result['param_errors'][0]:.3f}, "
            f"mean={result['params'][1]:.3f}±{result['param_errors'][1]:.3f}, "
            f"sigma={result['params'][2]:.3f}±{result['param_errors'][2]:.3f}"
        )
        print(f"Chi-squared: {result['chi2']:.3f}")
        print(f"Reduced chi-squared: {result['reduced_chi2']:.3f}")
        print(f"Degrees of freedom: {result['dof']}")
    else:
        print(f"Fit failed: {result['error']}")
    print()

    # Plot results
    plot_fit_results(
        x,
        y_data,
        result,
        gaussian_function,
        uncertainties,
        title="Gaussian Function Fit",
        x_label="x",
        y_label="y",
    )

    return result


if __name__ == "__main__":
    print("Chi-squared Fitting Tests")
    print("=" * 50)

    # Run tests
    linear_result = test_linear_fit()
    gaussian_result = test_gaussian_fit()

    print("All tests completed!")
