# Crystal Analysis Pipeline (Fiji + Python)

This project provides an automated and interactive pipeline for the morphometric and color analysis of crystals. It combines a user-friendly graphical interface (built with Python) and the powerful image processing capabilities of Fiji (ImageJ).

## Features

*   **User-Friendly GUI**: A modern interface built with `customtkinter` to easily manage input and output directories.
*   **Fiji Integration**: Automates the execution of an ImageJ Macro for image segmentation.
*   **Interactive Segmentation**: Pauses during execution to allow the user to manually edit and refine Regions of Interest (ROIs) for accurate crystal selection.
*   **Color Homogenization**: Standardizes crystal colors using a viridis color map.
*   **Data Analysis**: Automatically processes the CSV output from Fiji to provide a summary of crystal sizes (count, average area, average Feret diameter).

## Prerequisites

To run this project, you will need:

1.  **Python 3.x**
2.  **Fiji (ImageJ)**: Download and install from [fiji.sc](https://fiji.sc/). The app expects the executable `ImageJ-win64.exe`.

### Python Dependencies

Install the required Python libraries using pip:

```bash
pip install customtkinter pandas
```

## Usage

1.  Clone this repository:
    ```bash
    git clone https://github.com/silviaramirez-BioT/crystal_analisys_fiji.git
    cd crystal_analisys_fiji
    ```
2.  Run the Python application:
    ```bash
    python app.py
    ```
3.  In the application interface:
    *   **Select Input Folder**: Choose the folder containing your crystal images (`.jpg` or `.tif`).
    *   **Select Output Folder**: Choose an empty folder where the results will be saved.
    *   **Click "1. Iniciar Segmentación en Fiji"**: This will launch Fiji. *Note: If Fiji is not found in the default path, you will be prompted to select the `ImageJ-win64.exe` executable.*
4.  **Interactive Fiji Process**:
    *   Fiji will process the images and pause, showing you a suggested mask.
    *   Review the generated ROIs. Delete incorrect ones or draw new ones using the Freehand tool.
    *   Click "OK" on the dialog box when you are satisfied with the selections.
5.  **Generate Report**:
    *   Back in the Python interface, click "**2. Generar Reporte de Tamaños (CSV)**".
    *   The app will process the data and display a summary of the analyzed crystals.

## Output Structure

The pipeline generates the following files in your selected output directory:
*   `01_Color_Homogeneizado/`: Images with standardized colors and scale bars.
*   `02_Mascaras_Binarias/`: The final binary masks used for measurement.
*   `03_Control_Visual/`: Images with red outlines showing the measured ROIs.
*   `Resultados_Cristales.csv`: The raw data containing measurements (Area, Perimeter, Feret, Mean, StdDev) for every single crystal analyzed.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
