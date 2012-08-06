package com.nwalsh.xalan;

import org.xml.sax.helpers.AttributesImpl;
import org.xml.sax.SAXException;
import org.w3c.dom.Element;
import org.apache.xml.utils.DOMBuilder;
import org.apache.xml.utils.AttList;

import com.nwalsh.xalan.Callout;


/**
 * <p>Utility class for the Verbatim extension (ignore this).</p>
 *
 * <p>$Id$</p>
 *
 * <p>Copyright (C) 2000, 2001 Norman Walsh.</p>
 *
 * <p><b>Change Log:</b></p>
 * <dl>
 * <dt>1.0</dt>
 * <dd><p>Initial release.</p></dd>
 * </dl>
 *
 * @author Norman Walsh
 * <a href="mailto:ndw@nwalsh.com">ndw@nwalsh.com</a>
 *
 * @see Verbatim
 *
 * @version $Id$
 **/

public class FormatGraphicCallout extends FormatCallout {
  String graphicsPath = "";
  String graphicsExt = "";
  int graphicsMax = 0;
  String iconSize = "";

  public FormatGraphicCallout(String path, String ext, int max, String size, boolean fo) {
    graphicsPath = path;
    graphicsExt = ext;
    graphicsMax = max;
    stylesheetFO = fo;
    iconSize = size;

    //System.out.println("Size: " + size);

  }

  public void formatCallout(DOMBuilder rtf,
			    Callout callout) {
    Element area = callout.getArea();
    int num = callout.getCallout();
    String label = areaLabel(area);
    String id = areaID(area);

    try {
      if (label == null && num <= graphicsMax) {
	AttributesImpl imgAttr = new AttributesImpl();
	String ns = "";
	String prefix = "";
	String imgName = "";

	if (stylesheetFO) {
	  ns = foURI;
	  prefix = "fo:"; // FIXME: this could be a problem...
	  imgName = "external-graphic";
	  imgAttr.addAttribute("", "src", "src", "CDATA", "url(" +
			       graphicsPath + num + graphicsExt + ")");
	  imgAttr.addAttribute("", "id", "id", "ID", id);
	  imgAttr.addAttribute("", "content-width", "content-width", "CDATA", iconSize);
	  imgAttr.addAttribute("", "width", "width", "CDATA", iconSize);

	} else {
	  ns = "";
	  prefix = "";
	  imgName = "img";
	  imgAttr.addAttribute("", "src", "src", "CDATA",
			       graphicsPath + num + graphicsExt);
	  imgAttr.addAttribute("", "alt", "alt", "CDATA", label);
	  imgAttr.addAttribute("", "id", "id", "ID", id);
	}

	startSpan(rtf, id);
	rtf.startElement(ns, imgName, prefix+imgName, imgAttr);
	rtf.endElement(ns, imgName, prefix+imgName);
	endSpan(rtf);
      } else {
	formatTextCallout(rtf, callout);
      }
    } catch (SAXException e) {
      System.out.println("SAX Exception in graphics formatCallout");
    }
  }
}
