export const FALLBACK_IMAGE = '/imagenes/hunnabpng.png';

export const HOME_CATEGORY_KEYS = ['collares', 'pulseras', 'anillos'];

// Definicion de categorias y subcategorias navegables por hash.
export const CATEGORIES = {
  collares: {
    title: 'Collares',
    desc: 'Disenos artesanales creados con dedicacion para expresar tu esencia.',
    heroImg: 'imagenes/Collar_Nautilus.jpeg',
    heroImgHover: 'imagenes/Collar_Nautilus_Negro.jpeg',
    products: ['gargantilla-luna', 'gargantilla-perla', 'gargantilla-minimal', 'corbatin-satin', 'corbatin-oro'],
    tabs: [
      {
        id: 'caballero',
        label: 'Para Caballero',
        content:
          'Accesorios con caracter y diseno moderno, ideales para un estilo autentico.',
      },
      {
        id: 'dama',
        label: 'Para Dama',
        content:
          'Disenos delicados que realzan tu estilo y aportan elegancia para cada ocasion.',
      },
    ],
  },
  'collares/caballero': {
    title: 'Collares Caballero',
    desc: 'Collares cortos para usar solos o combinar en capas.',
    heroImg: 'imagenes/Collar_Nautilus.jpeg',
    heroImgHover: 'imagenes/Collar_Nautilus_Negro.jpeg',
    products: ['gargantilla-luna', 'gargantilla-perla', 'gargantilla-minimal'],
  },
  'collares/dama': {
    title: 'Collares Dama',
    desc: 'Collares cortos para dama que aportan delicadeza y estilo.',
    heroImg: 'imagenes/Anillo_Muestra.jpeg',
    heroImgHover: 'imagenes/Anillo_Modelo.jpeg',
    products: ['corbatin-satin', 'corbatin-oro'],
  },
  anillos: {
    title: 'Anillos',
    desc: 'Anillos clasicos y modernos para cualquier ocasion.',
    heroImg: 'imagenes/Anillo_Modelo.jpeg',
    heroImgHover: 'imagenes/Anillo_Muestra.jpeg',
    products: ['arracadas-clasicas'],
  },
  pulseras: {
    title: 'Pulseras',
    desc: 'Piezas cuidadosamente elaboradas que combinan diseno y detalle.',
    heroImg: 'imagenes/Pulsera_Volcanica.png',
    heroImgHover: 'imagenes/Pulseras_Onyx.png',
    products: ['pulsera-nudo', 'pulsera-bicolor', 'pulsera-cuarzo-rosa', 'pulsera-amazonita', 'pulsera-ojo-tigre', 'pulsera-amatista', 'pulsera-agata-musgosa', 'pulsera-labradorita'],
    tabs: [
      {
        id: 'caballero',
        label: 'Para Caballero',
        content: 'Pulseras con estilo sobrio y materiales resistentes.',
      },
      {
        id: 'dama',
        label: 'Para Dama',
        content: 'Pulseras delicadas y versatiles para cualquier ocasion.',
      },
    ],
  },
  'pulseras/caballero': {
    title: 'Pulseras Para Caballero',
    desc: 'Pulseras sobrias para uso diario.',
    heroImg: 'imagenes/Pulsera_Volcanica.png',
    heroImgHover: 'imagenes/Pulseras_Onyx.png',
    products: ['pulsera-nudo', 'pulsera-bicolor'],
  },
  'pulseras/dama': {
    title: 'Pulseras Para Dama',
    desc: 'Pulseras delicadas y versatiles.',
    heroImg: 'imagenes/Pulseras_Onyx.png',
    heroImgHover: 'imagenes/Pulsera_Volcanica.png',
    products: ['pulsera-cuarzo-rosa', 'pulsera-amazonita', 'pulsera-ojo-tigre', 'pulsera-amatista', 'pulsera-agata-musgosa', 'pulsera-labradorita'],
  },
};

// Catalogo base de productos.
export const PRODUCTS = {
  'gargantilla-luna': {
    title: 'Collar Aquamarina',
    price: 250,
    stock: 15,
    img: 'imagenes/Collar_Aquamarina.jpeg',
    imgHover: 'imagenes/Collar_Nautilus_Negro.jpeg',
    sizes: ['16"', '18"', '20"', '24"', '30"', '36"'],
    desc: 'Collar artesanal inspirado en la frescura del mar, elaborado con técnica de alambrismo y detalles en baño de oro de 18k. El alambre cuenta con una capa protectora que ayuda a prolongar su duración. La aquamarina, conocida por sus suaves tonos azul mar, se asocia con la tranquilidad, la claridad mental y la comunicación.',
  },
  'gargantilla-perla': {
    title: 'Collar Ágata Azul',
    price: 270,
    stock: 12,
    img: 'imagenes/Collar_Nautilus.jpeg',
    imgHover: 'imagenes/Collar_Nautilus_Negro.jpeg',
    sizes: ['16"', '18"', '20"', '24"', '30"', '36"'],
    desc: 'Diseñado a mano con técnica de alambrismo y elegantes detalles en baño de oro de 18k. El recubrimiento de polímero del alambre ayuda a mantener la pieza en excelente estado por más tiempo. El ágata azul, reconocida por sus vetas suaves y tonos relajantes, se asocia con la calma, la estabilidad emocional y la confianza.',
  },
  'gargantilla-minimal': {
    title: 'Collar Libelula',
    price: 170,
    stock: 18,
    img: 'imagenes/Collar_Libelula.jpeg',
    imgHover: 'imagenes/Collar_Nautilus_Negro.jpeg',
    sizes: ['16"', '18"', '20"', '24"', '30"', '36"'],
    desc: 'Collar delicado elaborado con piedra natural y un encantador dije de libélula, símbolo de transformación y libertad. Su diseño elegante y sutil lo convierte en el accesorio perfecto para darle un toque único, natural y brillante a cualquier outfit.',
  },
  'corbatin-satin': {
    title: 'Collar Cuarzo Blanco',
    price: 280,
    stock: 10,
    img: 'imagenes/Collar_Amatista.jpeg',
    sizes: ['16"', '18"', '20"', '24"', '30"', '36"'],
    desc: 'Pieza artesanal creada con materiales de alta calidad y delicados acabados en baño de oro de 18k. El alambre recubierto brinda mayor resistencia y durabilidad. El cuarzo blanco, apreciado por su pureza y brillo natural, se relaciona con la energía, la armonía y la claridad.',
  },
  'corbatin-oro': {
    title: 'Collar Oro',
    price: 310,
    stock: 8,
    img: 'imagenes/Collar_Arbolvida.jpeg',
    sizes: ['16"', '18"', '20"', '24"', '30"', '36"'],
  },
  'arracadas-clasicas': {
    title: 'Anillo Piedra Luna',
    price: 260,
    stock: 14,
    img: 'imagenes/Anillo_Muestra.jpeg',
    sizes: ['3', '3.5', '4', '4.5', '5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11', '11.5', '12', '12.5', '13'],
    desc: 'Diseño delicado trabajado con técnica de alambrismo y acabado en baño de oro de 18k. Su recubrimiento protector aporta mayor durabilidad y calidad a la pieza. La piedra luna destaca por su brillo iridiscente y se relaciona con la intuición, la energía femenina y la calma emocional.',
  },
  'pulsera-nudo': {
    title: 'Pulsera Onyx',
    price: 180,
    stock: 20,
    img: 'imagenes/Pulsera_Volcanica.png',
    sizes: ['Extrapequeña', 'Pequeña', 'Mediana', 'Grande', 'Extragrande', 'XX-grande', 'XXX-grande'],
    desc: 'Pulseras elaboradas artesanalmente con piedras naturales y detalles únicos que combinan elegancia, protección y estilo. Cada pieza está diseñada con materiales de alta calidad y acabados cuidadosamente seleccionados para crear accesorios versátiles, modernos y llenos de personalidad.',
  },
  'pulsera-cuarzo-rosa': {
    title: 'Pulsera Cuarzo Rosa',
    price: 190,
    stock: 15,
    img: 'imagenes/Pulsera_CuarzoRosa.png',
    sizes: ['Extrapequeña', 'Pequeña', 'Mediana', 'Grande', 'Extragrande', 'XX-grande', 'XXX-grande'],
    desc: 'Diseño artesanal trabajado a mano con técnica de alambrismo y acabado en baño de oro de 18k. El alambre incluye recubrimiento de polímero para mayor resistencia y durabilidad. El cuarzo rosa, reconocido como la piedra del amor incondicional, se relaciona con la armonía, el amor propio y la sanación emocional.',
  },
  'pulsera-amazonita': {
    title: 'Pulsera Amazonita',
    price: 190,
    stock: 15,
    img: 'imagenes/Pulsera_Amazonita.png',
    sizes: ['Extrapequeña', 'Pequeña', 'Mediana', 'Grande', 'Extragrande', 'XX-grande', 'XXX-grande'],
    desc: 'Pieza artesanal creada con técnica de alambrismo y materiales de alta calidad en baño de oro de 18k. Su alambre cuenta con recubrimiento protector que ayuda a conservar su acabado por más tiempo. La amazonita destaca por sus tonos verde-azulados y se asocia con la calma, el equilibrio emocional y la comunicación.',
  },
  'pulsera-ojo-tigre': {
    title: 'Pulsera Ojo de Tigre',
    price: 200,
    stock: 12,
    img: 'imagenes/Pulsera_OjoTigre.png',
    sizes: ['Extrapequeña', 'Pequeña', 'Mediana', 'Grande', 'Extragrande', 'XX-grande', 'XXX-grande'],
    desc: 'Pulsera hecha a mano con delicados detalles en alambrismo y materiales con baño de oro de 18k. El recubrimiento de polímero del alambre ayuda a prolongar su durabilidad. El ojo de tigre es una piedra vinculada con la protección, la seguridad personal, la confianza y la prosperidad.',
  },
  'pulsera-amatista': {
    title: 'Pulsera Amatista',
    price: 195,
    stock: 14,
    img: 'imagenes/Pulsera_Amatista.png',
    sizes: ['Extrapequeña', 'Pequeña', 'Mediana', 'Grande', 'Extragrande', 'XX-grande', 'XXX-grande'],
    desc: 'Creada artesanalmente con técnica de alambrismo y materiales de alta calidad en baño de oro de 18k. El alambre posee un recubrimiento especial que brinda mayor durabilidad. La amatista, conocida por su intenso color violeta, se asocia con la tranquilidad, la claridad mental y el equilibrio energético.',
  },
  'pulsera-agata-musgosa': {
    title: 'Pulsera Ágata Musgosa',
    price: 195,
    stock: 12,
    img: 'imagenes/Pulsera_AgataMusgosa.png',
    sizes: ['Extrapequeña', 'Pequeña', 'Mediana', 'Grande', 'Extragrande', 'XX-grande', 'XXX-grande'],
    desc: 'Pulsera artesanal diseñada con técnica de alambrismo y acabado en baño de oro de 18k. El alambre cuenta con recubrimiento de polímero para conservar mejor su calidad y brillo. El ágata musgosa, reconocida por sus tonos inspirados en la naturaleza, se relaciona con la estabilidad, la abundancia y la conexión natural.',
  },
  'pulsera-labradorita': {
    title: 'Pulsera Labradorita',
    price: 205,
    stock: 10,
    img: 'imagenes/Pulsera_Labradorita.png',
    sizes: ['Extrapequeña', 'Pequeña', 'Mediana', 'Grande', 'Extragrande', 'XX-grande', 'XXX-grande'],
    desc: 'Diseño elaborado a mano con técnica de alambrismo y materiales de alta calidad en baño de oro de 18k. Su alambre recubierto ayuda a mantener la pieza resistente y duradera. La labradorita, famosa por sus destellos iridiscentes, se asocia con la intuición, la protección energética y la transformación personal.',
  },
  'pulsera-bicolor': {
    title: 'Pulsera Piedra Volcanica',
    price: 210,
    stock: 13,
    img: 'imagenes/Pulseras_Onyx.png',
    sizes: ['Extrapequeña', 'Pequeña', 'Mediana', 'Grande', 'Extragrande', 'XX-grande', 'XXX-grande'],
    desc: 'Una pieza elegante creada a mano con detalles en baño de oro de 18k y acabado artesanal. El alambre recubierto con polímero ayuda a conservar su brillo y resistencia por más tiempo. El ónix, de intenso tono negro, es una piedra asociada con la protección, la fuerza interior y el equilibrio emocional.',
  },
};

// Tabs por defecto del acordeon informativo de categoria.
export const DEFAULT_CATEGORY_TABS = [
  {
    id: 'descripcion',
    label: 'Descripción',
    content: (category) => category.desc,
  },
  {
    id: 'materiales',
    label: 'Materiales',
    content: () => 'Materiales de la coleccion (editable).',
  },
  {
    id: 'cuidados',
    label: 'Cuidados',
    content: () => 'Evita quimicos, guarda por separado y limpia con pano suave.',
  },
];
