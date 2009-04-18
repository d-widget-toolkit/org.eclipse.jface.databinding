/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Brad Reynolds - bug 164653
 *     Matt Carter - bug 170668
 *     Brad Reynolds - bug 170848
 *******************************************************************************/
module org.eclipse.jface.internal.databinding.swt.ControlObservableValue;
import org.eclipse.jface.internal.databinding.swt.SWTProperties;

import java.lang.all;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.jface.internal.databinding.provisional.swt.AbstractSWTObservableValue;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.widgets.Control;

/**
 * @since 1.0
 * 
 */
public class ControlObservableValue : AbstractSWTObservableValue {

    private final Control control;

    private final String attribute;

    private Object valueType;
    
    private static Map SUPPORTED_ATTRIBUTES;
    static this() {
        SUPPORTED_ATTRIBUTES = new HashMap();
        SUPPORTED_ATTRIBUTES.put(SWTProperties.ENABLED, Boolean.TYPE);
        SUPPORTED_ATTRIBUTES.put(SWTProperties.VISIBLE, Boolean.TYPE);
        SUPPORTED_ATTRIBUTES.put(SWTProperties.TOOLTIP_TEXT, Class.fromType!(String));
        SUPPORTED_ATTRIBUTES.put(SWTProperties.FOREGROUND, Class.fromType!(Color));
        SUPPORTED_ATTRIBUTES.put(SWTProperties.BACKGROUND, Class.fromType!(Color));
        SUPPORTED_ATTRIBUTES.put(SWTProperties.FONT, Class.fromType!(Font));
    }
    
    /**
     * @param control
     * @param attribute
     */
    public this(Control control, String attribute) {
        super(control);
        this.control = control;
        this.attribute = attribute;
        if (SUPPORTED_ATTRIBUTES.keySet().contains(attribute)) {
            this.valueType = SUPPORTED_ATTRIBUTES.get(attribute); 
        } else {
            throw new IllegalArgumentException(null);
        }
    }

    public void doSetValue(Object value) {
        Object oldValue = doGetValue();
        if (attribute.equals(SWTProperties.ENABLED)) {
            control.setEnabled((cast(Boolean) value).booleanValue());
        } else if (attribute.equals(SWTProperties.VISIBLE)) {
            control.setVisible((cast(Boolean) value).booleanValue());
        } else if (attribute.equals(SWTProperties.TOOLTIP_TEXT)) {
            control.setToolTipText(stringcast(value));
        } else if (attribute.equals(SWTProperties.FOREGROUND)) {
            control.setForeground(cast(Color) value);
        } else if (attribute.equals(SWTProperties.BACKGROUND)) {
            control.setBackground(cast(Color) value);
        } else if (attribute.equals(SWTProperties.FONT)) {
            control.setFont(cast(Font) value);
        }
        fireValueChange(Diffs.createValueDiff(oldValue, value));
    }

    public Object doGetValue() {
        if (attribute.equals(SWTProperties.ENABLED)) {
            return control.getEnabled() ? Boolean.TRUE : Boolean.FALSE;
        }
        if (attribute.equals(SWTProperties.VISIBLE)) {
            return control.getVisible() ? Boolean.TRUE : Boolean.FALSE;
        }
        if (attribute.equals(SWTProperties.TOOLTIP_TEXT)) {
            return stringcast(control.getToolTipText());            
        }
        if (attribute.equals(SWTProperties.FOREGROUND))  {
            return control.getForeground();
        }
        if (attribute.equals(SWTProperties.BACKGROUND)) {
            return control.getBackground();
        }
        if (attribute.equals(SWTProperties.FONT)) {
            return control.getFont();
        }
        
        return null;
    }

    public Object getValueType() {
        return valueType;
    }
}
