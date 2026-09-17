import customtkinter as ctk
import pandas as pd
import subprocess
import os
from tkinter import filedialog, messagebox

ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class CrystalApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("DevSciLab - Pipeline de Cristales")
        self.geometry("550x450")
        
        # Título
        self.label_title = ctk.CTkLabel(self, text="Análisis de Cristales (Morfometría y Color)", font=("Arial", 18, "bold"))
        self.label_title.pack(pady=20)
        
        self.dir_input = ""
        self.dir_salida = ""

        # Selección de entrada
        self.btn_in = ctk.CTkButton(self, text="Seleccionar Carpeta Entrada", width=250, command=self.select_in)
        self.btn_in.pack(pady=5)
        self.lbl_in = ctk.CTkLabel(self, text="Ninguna carpeta seleccionada", text_color="gray")
        self.lbl_in.pack(pady=0)

        # Selección de salida
        self.btn_out = ctk.CTkButton(self, text="Seleccionar Carpeta Salida", width=250, command=self.select_out)
        self.btn_out.pack(pady=5)
        self.lbl_out = ctk.CTkLabel(self, text="Ninguna carpeta seleccionada", text_color="gray")
        self.lbl_out.pack(pady=0)

        # Botón 1: Ejecutar Fiji
        self.btn_fiji = ctk.CTkButton(self, text="1. Iniciar Segmentación en Fiji", width=250, height=40, command=self.run_macro)
        self.btn_fiji.pack(pady=15)
        
        # Botón 2: Procesar Datos
        self.btn_datos = ctk.CTkButton(self, text="2. Generar Reporte de Tamaños (CSV)", width=250, height=40, command=self.process_csv)
        self.btn_datos.pack(pady=5)

    def select_in(self):
        folder = filedialog.askdirectory(title="Selecciona CARPETA entrada")
        if folder:
            # Reemplazar barras para evitar problemas en Fiji
            folder = folder.replace("\\", "/") + "/"
            self.dir_input = folder
            self.lbl_in.configure(text=folder)

    def select_out(self):
        folder = filedialog.askdirectory(title="Selecciona CARPETA salida")
        if folder:
            # Reemplazar barras para evitar problemas en Fiji
            folder = folder.replace("\\", "/") + "/"
            self.dir_salida = folder
            self.lbl_out.configure(text=folder)

    def run_macro(self):
        if not self.dir_input or not self.dir_salida:
            messagebox.showwarning("Atención", "Por favor selecciona primero las carpetas de entrada y salida.")
            return

        # Asegúrate de que esta ruta a Fiji es correcta en tu ordenador
        ruta_fiji = r"C:\Program Files\Fiji.app\ImageJ-win64.exe" 
        if not os.path.exists(ruta_fiji):
            messagebox.showinfo("Fiji no encontrado", "No se encontró Fiji en la ruta por defecto. Por favor, selecciona el archivo 'ImageJ-win64.exe' de la carpeta donde instalaste Fiji.")
            ruta_fiji = filedialog.askopenfilename(title="Selecciona ImageJ-win64.exe", filetypes=[("Ejecutables", "*.exe")])
            if not ruta_fiji:
                return # Si el usuario cancela la selección, salimos
        
        ruta_macro = r"C:\Users\silvi\OneDrive\Desktop\Codigo_Cristales_Davit\codigo_cristales.ijm"
        
        # Pasamos los argumentos separados por un asterisco
        args = f"{self.dir_input}*{self.dir_salida}"

        try:
            # Llama a Fiji sin modo 'headless' para que la interfaz gráfica aparezca y puedas usar el waitForUser
            subprocess.Popen([ruta_fiji, "-macro", ruta_macro, args])
        except Exception as e:
            messagebox.showerror("Error", f"Verifica la ruta de Fiji:\n{e}")

    def process_csv(self):
        if self.dir_salida:
            csv_path = os.path.join(self.dir_salida, "Resultados_Cristales.csv")
            if os.path.exists(csv_path):
                file_path = csv_path
            else:
                file_path = filedialog.askopenfilename(title="Selecciona Resultados_Cristales.csv", filetypes=[("CSV files", "*.csv")])
        else:
            file_path = filedialog.askopenfilename(title="Selecciona Resultados_Cristales.csv", filetypes=[("CSV files", "*.csv")])
            
        if file_path:
            try:
                df = pd.read_csv(file_path)
                conteo_total = len(df)
                area_promedio = df['Area'].mean()
                feret_promedio = df['Feret_Diameter'].mean()
                
                resumen = (f"Análisis completado exitosamente.\n\n"
                           f"Cristales totales cuantificados: {conteo_total}\n"
                           f"Área promedio: {area_promedio:.2f}\n"
                           f"Diámetro (Feret) promedio: {feret_promedio:.2f}")
                
                messagebox.showinfo("Resumen de Tallas", resumen)
            except Exception as e:
                messagebox.showerror("Error de lectura", f"No se pudo leer el CSV:\n{e}")

if __name__ == "__main__":
    app = CrystalApp()
    app.mainloop()
