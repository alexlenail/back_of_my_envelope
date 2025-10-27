p_config is missing a sum before delta G



At the moment, there does not exist an assay which reports directly on the occupancies of transcription factor binding sites across the genome in single cells. However, we can measure chromatin accessibility in single cells via [single-cell ATAC-seq](https://www.10xgenomics.com/products/single-cell-atac), which reports a 1-dimensional projection of TFBS occupancies. This blog post explores an approach to lift single cell ATAC signals onto the space of TFBS occupancies, i.e. to deconvolve ATAC signals into TF binding tracks.

Our approach relies on an orthogonal suite of experiments characterizing transcription factor binding in vitro. In [High-Throughput SELEX](https://genome.cshlp.org/content/20/6/861.long) experiments, the...

---
## Misc. General

scroll the TOC independently

the svg thing is super annoying



blog posts should be tagged by programming language automatically

fix mobile view

collapse / show all code cells macro
<button class="btn" type="button">Open Code</button><button class="btn" type="button">Fold Code</button>

does #collapse need to be the first line? open issue so it can be the last too


google SEO / tracking

how to cite my blog posts




<script>
window.addEventListener('DOMContentLoaded', () => {

    const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
            const id = entry.target.getAttribute('id');
            if (entry.intersectionRatio > 0) {
                document.querySelector(`.toc-entry > a[href="#${id}"]`).classList.add('active');
                unclaimed = false;
            } else {
                document.querySelector(`.toc-entry > a[href="#${id}"]`).classList.remove('active');
            }
        });
    });

    // Track all sections that have an `id` applied
    document.querySelectorAll('h2, h3, h4').forEach((heading) => {
        observer.observe(heading);
    });

});
</script>



---
## Hessian:

try voila:
https://voila.readthedocs.io/en/stable/



---
## EPKI:




test my high-D vis function with a known, high-D ellipsoid.




"differential equation constrained optimization"

lambda, once solved, encodes the...



