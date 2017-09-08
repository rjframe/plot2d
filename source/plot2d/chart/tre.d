module plot2d.chart.tre;

public import plot2d.chart.base;

///
class TreChart : BaseChart!TreStat
{
protected:
    override void expandViewport(size_t i, ref const TreStat val)
    {
        if (i == 0) vp = Viewport.initial(val.minPnt);
        else
        {
            vp.expand(val.minPnt);
            vp.expand(val.maxPnt);
            vp.expand(val.valPnt);
        }
    }

public:

    Color fillUp, fillDown, stroke, strokeLimUp, strokeLimDown;

    double disaster;
    double disasterCoef = 3; // must be > 1

    this(Color stroke,
         Color strokeLimUp, Color fillUp,
         Color strokeLimDown, Color fillDown,
         void delegate(ref typeof(buffer)) fd)
    {
        this.stroke = stroke;
        this.fillUp = fillUp;
        this.fillDown = fillDown;
        this.strokeLimUp = strokeLimUp;
        this.strokeLimDown = strokeLimDown;
        super(fd);
    }

    override
    {
        void update()
        {
            super.update();

            auto avg_diff = 0.0;
            foreach (a, b; lockstep(buffer.data[0..$-1], buffer.data[1..$]))
                avg_diff += b.tm - a.tm;
            avg_diff /= buffer.data.length;
            disaster = avg_diff * disasterCoef;
        }

        void draw(Ctx cr, Trtor tr, Style style)
        {
            auto limlinewidth = style.number.get("limlinewidth", 1);
            auto linewidth = style.number.get("linewidth", 2);

            if (buffer.data.length == 0) return;

            cr.clipViewport(tr.inPadding);

            auto lst = buffer.data.front;

            foreach (val; buffer.data[1..$])
            {
                //if (val.tm - lst.tm > disaster)
                //{ lst = val; continue; }

                cr.setColor(fillUp);
                cr.lineP2P(tr.toDA(lst.maxPnt),
                           tr.toDA(lst.valPnt),
                           tr.toDA(val.maxPnt));
                cr.fill();
                cr.lineP2P(tr.toDA(lst.valPnt),
                           tr.toDA(val.maxPnt),
                           tr.toDA(val.valPnt));
                cr.fill();

                cr.setColor(fillDown);
                cr.lineP2P(tr.toDA(lst.valPnt),
                           tr.toDA(lst.minPnt),
                           tr.toDA(val.valPnt));
                cr.fill();
                cr.lineP2P(tr.toDA(lst.minPnt),
                           tr.toDA(val.valPnt),
                           tr.toDA(val.minPnt));
                cr.fill();

                cr.setLineWidth(limlinewidth);

                cr.setColor(strokeLimUp);
                cr.lineP2P(tr.toDA(lst.maxPnt), tr.toDA(val.maxPnt));
                cr.stroke();

                cr.setColor(strokeLimDown);
                cr.lineP2P(tr.toDA(lst.minPnt), tr.toDA(val.minPnt));
                cr.stroke();

                cr.setLineWidth(linewidth);    
                cr.setColor(stroke);
                cr.lineP2P(tr.toDA(lst.valPnt), tr.toDA(val.valPnt));
                cr.stroke();

                lst = val;
            }
        }
    }
}