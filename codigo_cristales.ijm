// =======================================================
// MACRO CRISTALES - EDICIÓN INTERACTIVA Y HOMOGENIZACIÓN
// Basado en la arquitectura de ROI-editable.ijm
// =======================================================

run("Close All");
print("\\Clear");

// 1. Configuración de mediciones solicitadas
// Área, Desviación Estándar, Perímetro, Diámetro de Feret (máximo)
run("Set Measurements...", "area mean standard perimeter feret's display redirect=None decimal=3");
run("Options...", "iterations=1 count=1 black");
setForegroundColor(255, 255, 255);
setBackgroundColor(0, 0, 0);

// 2. Selección de directorios
args = getArgument();
if (args != "") {
    parts = split(args, "*");
    dirInput = parts[0];
    dirSalida = parts[1];
} else {
    dirInput = getDirectory("Selecciona CARPETA entrada (fotos_cristales_tratar)");
    dirSalida = getDirectory("Selecciona carpeta SALIDA vacía");
}

// Crear subcarpetas organizadas
dirColor = dirSalida + "01_Color_Homogeneizado" + File.separator; File.makeDirectory(dirColor);
dirMascaras = dirSalida + "02_Mascaras_Binarias" + File.separator; File.makeDirectory(dirMascaras);
dirOutlines = dirSalida + "03_Control_Visual" + File.separator; File.makeDirectory(dirOutlines);

// Archivo CSV
f = File.open(dirSalida + "Resultados_Cristales.csv");
print(f, "Image_Name,Crystal_ID,Area,Perimeter,Feret_Diameter,Mean_Intensity,Std_Dev");

setBatchMode(false); 

list = getFileList(dirInput);
for (k = 0; k < list.length; k++) {
    fName = list[k];
    // Procesar solo imágenes y saltar las de referencia
    if ((endsWith(toLowerCase(fName), ".jpg") || endsWith(toLowerCase(fName), ".tif")) && indexOf(toLowerCase(fName), "_ref") == -1) {
        processCrystalImage(dirInput, fName);
    }
}

File.close(f);
showMessage("¡Terminado!", "Análisis de cristales completado con éxito.");

// ================= FUNCIONES =================

function processCrystalImage(dir, filename) {
    open(dir + filename);
    titulo = getTitle();
    safeTitle = replace(titulo, ".jpg", "");
    safeTitle = replace(safeTitle, ".tif", "");
    
    // 3. Homogeneización de Color (Tonos Azul, Verde, Amarillo)
    run("8-bit");
    // "viridis" genera un mapa exacto de azul a amarillo. Si prefieres más contraste, cambia a "Spectrum"
    run("viridis"); 
    run("RGB Color"); // Fija los colores
    rename("COLOR_" + titulo);
    
    // Duplicar para crear una máscara sugerida inicial
    run("Duplicate...", "title=Mascara_Base");
    run("8-bit");
    setAutoThreshold("Otsu dark");
    run("Convert to Mask");
    
    // 4. Configuración para la edición interactiva
    selectWindow("COLOR_" + titulo);
    setTool("freehand");
    roiManager("Reset"); 
    
    // Cargar la máscara sugerida al ROI manager si hay partículas claras
    selectWindow("Mascara_Base");
    run("Analyze Particles...", "size=10-Infinity add");
    selectWindow("COLOR_" + titulo);
    roiManager("Show All with labels");
    
    // --- PAUSA PARA DIBUJAR / EDITAR ---
    waitForUser("EDICIÓN DE MÁSCARA Y ROIs", "1. Revisa los ROIs generados automáticamente.\n2. Borra los incorrectos (Supr) o dibuja nuevos con Freehand y pulsa 't'.\n3. Usa tus imágenes '_ref' abiertas como guía.\n4. Pulsa OK cuando los cristales estén bien delimitados.");
    
    // Guardar Máscara Final actualizada
    getDimensions(width, height, channels, slices, frames);
    newImage("Mascara_Final", "8-bit black", width, height, 1);
    if (roiManager("count") > 0) { 
        roiManager("Deselect"); 
        roiManager("Fill"); 
    }
    saveAs("Tiff", dirMascaras + "Mascara_" + safeTitle);
    close();

    // --- BUCLE DE MEDICIÓN SEGURO ---
    selectWindow("COLOR_" + titulo);
    count = roiManager("count");
    if (count > 0) {
        for (r = 0; r < count; r++) {
            roiManager("Select", r); // Selección crítica individual para evitar promedios erróneos
            resetThreshold(); 
            run("Measure");
            
            area = getResult("Area", nResults-1); 
            perim = getResult("Perim.", nResults-1);
            feret = getResult("Feret", nResults-1);
            meanInt = getResult("Mean", nResults-1);
            stdDev = getResult("StdDev", nResults-1);
            
            print(f, titulo + "," + (r+1) + "," + area + "," + perim + "," + feret + "," + meanInt + "," + stdDev);
        }
        
        // Agregar Barra de Escala (Asume que la imagen está calibrada o se usan píxeles)
        // Ajusta el 'width' al tamaño de micrómetros que necesites.
        selectWindow("COLOR_" + titulo);
        run("Scale Bar...", "width=50 height=4 font=14 color=White background=None location=[Lower Right] bold");
        
        // Guardar imagen con color homogeneizado y barra
        saveAs("Jpeg", dirColor + "Color_" + safeTitle + ".jpg");
        
        // Guardar controles visuales con los contornos de los cristales (Outlines)
        roiManager("Show All without labels"); 
        roiManager("Set Color", "red");
        roiManager("Set Line Width", 2);
        run("Flatten");
        saveAs("Jpeg", dirOutlines + "Outlines_" + safeTitle + ".jpg");
    }
    
    roiManager("Delete");
    run("Close All");
    run("Clear Results");
}