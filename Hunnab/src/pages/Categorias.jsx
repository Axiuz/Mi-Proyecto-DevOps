import { useState, useEffect } from 'react';
import InfoAccordion from '../components/InfoAcordion';
import SizeGuideAccordion from '../components/SizeGuideAccordion';

/** Carrusel de la card: imagenes de los productos de la categoria actual. */
function CategoryCarousel({ images, title }) {
  const [idx, setIdx] = useState(0);

  useEffect(() => {
    if (images.length <= 1) return;
    const timer = setInterval(() => {
      setIdx((prev) => (prev + 1) % images.length);
    }, 3000);
    return () => clearInterval(timer);
  }, [images.length]);

  return (
    <div className="cat-carousel">
      {images.map((src, i) => (
        <img
          key={src + i}
          src={src}
          alt={`${title} ${i + 1}`}
          className={i === idx ? 'cat-carousel__active' : ''}
        />
      ))}
      <div className="cat-carousel__dots">
        {images.map((_, i) => (
          <button
            key={i}
            type="button"
            className={`cat-carousel__dot${i === idx ? ' cat-carousel__dot--on' : ''}`}
            onClick={() => setIdx(i)}
          />
        ))}
      </div>
    </div>
  );
}

/** Muestra una categoria, su contenido informativo y sus productos. */
function CategoryPage({ app, categoryKey }) {
  const category = app.catalog.getCategory(categoryKey);

  if (!category) {
    return (
      <div className="hero">
        <h1>No encontrado</h1>
        <p>
          La ruta no existe. Vuelve al <a href="#/">inicio</a>.
        </p>
      </div>
    );
  }

  const categoryProducts = app.catalog.getCategoryProducts(categoryKey);

  const categoryImages = categoryProducts.length
    ? categoryProducts.map(({ product }) => app.images.normalize(product.img))
    : [app.images.normalize(category.heroImg)];

  const genderTab = category.tabs?.length
    ? {
        id: 'por-genero',
        label: 'Por género',
        content: (
          <div className="gender-links">
            {category.tabs.map((tab) => (
              <a key={tab.id} className="gender-link" href={`#/${categoryKey}/${tab.id}`}>
                {tab.label}
              </a>
            ))}
          </div>
        ),
      }
    : null;

  return (
    <>
      <div className="crumb">Inicio / {category.title}</div>
      <div className="cat-card">
        <div className="cat-card__grid">
          <div>
            <h1 style={{ margin: '0 0 6px' }}>{category.title}</h1>
            <p style={{ margin: 0, color: 'var(--muted)' }}>{category.desc}</p>
            <InfoAccordion
              app={app}
              category={category}
              categoryKey={categoryKey}
              extraTabs={genderTab ? [genderTab] : []}
            />
          </div>
          <CategoryCarousel images={categoryImages} title={category.title} />
        </div>
        <SizeGuideAccordion categoryKey={categoryKey} />
      </div>

      <div className="grid">
        {categoryProducts.map(({ id, product }) => {
          const image = app.images.normalize(product.img);
          return (
            <a key={id} className="card" href={`#/p/${id}`}>
              <div className="img-swap">
                <img className="base" src={image} alt={product.title} />
              </div>
              <div className="card__body">
                <strong>{product.title}</strong>
                <span>{app.currency.formatMXN(product.price)}</span>
                <span className={`card-stock ${product.stock <= 0 ? 'is-out' : ''}`}>
                  {product.stock <= 0 ? 'Sin stock' : `Stock: ${product.stock}`}
                </span>
              </div>
            </a>
          );
        })}
      </div>
    </>
  );
}

export default CategoryPage;
