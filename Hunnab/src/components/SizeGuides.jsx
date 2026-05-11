/** Guia de tamaños para collares: imagen completa con tabla, ilustracion e instrucciones. */
export function CollaresSizeGuide() {
  return (
    <div className="sg-imgs">
      <img src="imagenes/guia_collar_completa.png" alt="Guia de longitudes de collar" className="sg-img" />
    </div>
  );
}

/** Guia de tamaños para pulseras: tabla de medidas de muneca + instrucciones. */
export function PulserasSizeGuide() {
  return (
    <div className="sg-imgs">
      <img src="imagenes/guia_pulseras.png" alt="Tabla de medidas de pulseras" className="sg-img" />
      <img src="imagenes/guia_pulseras_instrucciones.png" alt="Instrucciones para medir pulseras" className="sg-img" />
    </div>
  );
}

/** Guia de tamaños para anillos: tabla de tallas + instrucciones. */
export function AnillosSizeGuide() {
  return (
    <div className="sg-imgs">
      <div className="sg-scroll">
        <img src="imagenes/guia_anillos.png" alt="Tabla de tallas de anillos" className="sg-img sg-img--portrait" />
      </div>
      <img src="imagenes/guia_anillos_instrucciones.png" alt="Instrucciones para medir anillos" className="sg-img" />
    </div>
  );
}
