/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Matt Carter - bug 170668
 *     Brad Reynolds - bug 170848
 *     Matthew Hall - bug 180746, bug 207844
 *     Michael Krauter, bug 180223
 *******************************************************************************/
module org.eclipse.jface.databinding.swt.SWTObservables;
import org.eclipse.jface.databinding.swt.ISWTObservableValue;

import java.lang.all;

import java.util.ArrayList;
import java.util.Iterator;
static import java.util.List;

import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.list.IObservableList;
import org.eclipse.jface.internal.databinding.internal.swt.LinkObservableValue;
import org.eclipse.jface.internal.databinding.swt.ButtonObservableValue;
import org.eclipse.jface.internal.databinding.swt.CComboObservableList;
import org.eclipse.jface.internal.databinding.swt.CComboObservableValue;
import org.eclipse.jface.internal.databinding.swt.CComboSingleSelectionObservableValue;
import org.eclipse.jface.internal.databinding.swt.CLabelObservableValue;
import org.eclipse.jface.internal.databinding.swt.ComboObservableList;
import org.eclipse.jface.internal.databinding.swt.ComboObservableValue;
import org.eclipse.jface.internal.databinding.swt.ComboSingleSelectionObservableValue;
import org.eclipse.jface.internal.databinding.swt.ControlObservableValue;
import org.eclipse.jface.internal.databinding.swt.DelayedObservableValue;
import org.eclipse.jface.internal.databinding.swt.LabelObservableValue;
import org.eclipse.jface.internal.databinding.swt.ListObservableList;
import org.eclipse.jface.internal.databinding.swt.ListObservableValue;
import org.eclipse.jface.internal.databinding.swt.ListSingleSelectionObservableValue;
import org.eclipse.jface.internal.databinding.swt.SWTProperties;
import org.eclipse.jface.internal.databinding.swt.ScaleObservableValue;
import org.eclipse.jface.internal.databinding.swt.ShellObservableValue;
import org.eclipse.jface.internal.databinding.swt.SpinnerObservableValue;
import org.eclipse.jface.internal.databinding.swt.TableSingleSelectionObservableValue;
import org.eclipse.jface.internal.databinding.swt.TextEditableObservableValue;
import org.eclipse.jface.internal.databinding.swt.TextObservableValue;
import org.eclipse.swt.custom.CCombo;
import org.eclipse.swt.custom.CLabel;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Link;
import org.eclipse.swt.widgets.List;
import org.eclipse.swt.widgets.Scale;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Spinner;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.Text;

/**
 * A factory for creating observables for SWT widgets
 * 
 * @since 1.1
 * 
 */
public class SWTObservables {

    private static java.util.List.List realms;
    static this(){
        realms = new ArrayList();
    }

    /**
     * Returns the realm representing the UI thread for the given display.
     * 
     * @param display
     * @return the realm representing the UI thread for the given display
     */
    public static Realm getRealm(Display display) {
        synchronized (realms) {
            for (Iterator it = realms.iterator(); it.hasNext();) {
                DisplayRealm displayRealm = cast(DisplayRealm) it.next();
                if (displayRealm.display is display) {
                    return displayRealm;
                }
            }
            DisplayRealm result = new DisplayRealm(display);
            realms.add(result);
            return result;
        }
    }

    /**
     * Returns an observable which delays notification of value change events
     * from <code>observable</code> until <code>delay</code> milliseconds
     * have passed since the last change event, or until a FocusOut event is
     * received from the underlying widget (whichever happens earlier). This
     * class helps to delay validation until the user stops typing. To notify
     * about pending changes, the returned observable value will fire a stale
     * event when the wrapped observable value fires a change event, but this
     * change is being delayed.
     * 
     * @param delay
     * @param observable
     * @return an observable which delays notification of value change events
     *         from <code>observable</code> until <code>delay</code>
     *         milliseconds have passed since the last change event.
     * 
     * @since 1.2
     */
    public static ISWTObservableValue observeDelayedValue(int delay, ISWTObservableValue observable) {
      return new DelayedObservableValue(delay, observable);
    }

    /**
     * @param control
     * @return an observable value tracking the enabled state of the given
     *         control
     */
    public static ISWTObservableValue observeEnabled(Control control) {
        return new ControlObservableValue(control, SWTProperties.ENABLED);
    }

    /**
     * @param control
     * @return an observable value tracking the visible state of the given
     *         control
     */
    public static ISWTObservableValue observeVisible(Control control) {
        return new ControlObservableValue(control, SWTProperties.VISIBLE);
    }

    /**
     * @param control
     * @return an observable value tracking the tooltip text of the given
     *         control
     */
    public static ISWTObservableValue observeTooltipText(Control control) {
        return new ControlObservableValue(control, SWTProperties.TOOLTIP_TEXT);
    }

    /**
     * Returns an observable observing the selection attribute of the provided
     * <code>control</code>. The supported types are:
     * <ul>
     * <li>org.eclipse.swt.widgets.Spinner</li>
     * <li>org.eclipse.swt.widgets.Button</li>
     * <li>org.eclipse.swt.widgets.Combo</li>
     * <li>org.eclipse.swt.custom.CCombo</li>
     * <li>org.eclipse.swt.widgets.List</li>
     * <li>org.eclipse.swt.widgets.Scale</li>
     * </ul>
     * 
     * @param control
     * @return observable value
     * @throws IllegalArgumentException
     *             if <code>control</code> type is unsupported
     */
    public static ISWTObservableValue observeSelection(Control control) {
        if (null !is cast(Spinner)control) {
            return new SpinnerObservableValue(cast(Spinner) control,
                    SWTProperties.SELECTION);
        } else if (null !is cast(Button)control) {
            return new ButtonObservableValue(cast(Button) control);
        } else if (null !is cast(Combo)control) {
            return new ComboObservableValue(cast(Combo) control,
                    SWTProperties.SELECTION);
        } else if (null !is cast(CCombo)control) {
            return new CComboObservableValue(cast(CCombo) control,
                    SWTProperties.SELECTION);
        } else if (null !is cast(List)control) {
            return new ListObservableValue(cast(List) control);
        } else if (null !is cast(Scale)control) {
            return new ScaleObservableValue(cast(Scale) control,
                    SWTProperties.SELECTION);
        }

        throw new IllegalArgumentException(
                "Widget [" ~ Class.fromObject(control).getName() ~ "] is not supported."); //$NON-NLS-1$//$NON-NLS-2$
    }

    /**
     * Returns an observable observing the minimum attribute of the provided
     * <code>control</code>. The supported types are:
     * <ul>
     * <li>org.eclipse.swt.widgets.Spinner</li>
     * <li>org.eclipse.swt.widgets.Scale</li>
     * </ul>
     * 
     * @param control
     * @return observable value
     * @throws IllegalArgumentException
     *             if <code>control</code> type is unsupported
     */
    public static ISWTObservableValue observeMin(Control control) {
        if (null !is cast(Spinner)control) {
            return new SpinnerObservableValue(cast(Spinner) control,
                    SWTProperties.MIN);
        } else if (null !is cast(Scale)control) {
            return new ScaleObservableValue(cast(Scale) control, SWTProperties.MIN);
        }

        throw new IllegalArgumentException(
                "Widget [" ~ Class.fromObject(control).getName() ~ "] is not supported."); //$NON-NLS-1$//$NON-NLS-2$
    }

    /**
     * Returns an observable observing the maximum attribute of the provided
     * <code>control</code>. The supported types are:
     * <ul>
     * <li>org.eclipse.swt.widgets.Spinner</li>
     * <li>org.eclipse.swt.widgets.Scale</li>
     * </ul>
     * 
     * @param control
     * @return observable value
     * @throws IllegalArgumentException
     *             if <code>control</code> type is unsupported
     */
    public static ISWTObservableValue observeMax(Control control) {
        if (null !is cast(Spinner)control) {
            return new SpinnerObservableValue(cast(Spinner) control,
                    SWTProperties.MAX);
        } else if (null !is cast(Scale)control) {
            return new ScaleObservableValue(cast(Scale) control, SWTProperties.MAX);
        }

        throw new IllegalArgumentException(
                "Widget [" ~ Class.fromObject(control).getName() ~ "] is not supported."); //$NON-NLS-1$//$NON-NLS-2$
    }

    /**
     * Returns an observable observing the text attribute of the provided
     * <code>control</code>. The supported types are:
     * <ul>
     * <li>org.eclipse.swt.widgets.Text</li>
     * </ul>
     * 
     * <li>org.eclipse.swt.widgets.Label</li>
     * @param control
     * @param event event type to register for change events
     * @return observable value
     * @throws IllegalArgumentException
     *             if <code>control</code> type is unsupported
     */
    public static ISWTObservableValue observeText(Control control, int event) {
        if (null !is cast(Text)control) {
            return new TextObservableValue(cast(Text) control, event);
        }

        throw new IllegalArgumentException(
                "Widget [" ~ Class.fromObject(control).getName() ~ "] is not supported."); //$NON-NLS-1$//$NON-NLS-2$
    }

    /**
     * Returns an observable observing the text attribute of the provided
     * <code>control</code>. The supported types are:
     * <ul>
     * <li>org.eclipse.swt.widgets.Label</li>
     * <li>org.eclipse.swt.widgets.Link (as of 1.2)</li>
     * <li>org.eclipse.swt.custom.Label</li>
     * <li>org.eclipse.swt.widgets.Combo</li>
     * <li>org.eclipse.swt.custom.CCombo</li>
     * <li>org.eclipse.swt.widgets.Shell</li>
     * </ul>
     * 
     * @param control
     * @return observable value
     * @throws IllegalArgumentException
     *             if <code>control</code> type is unsupported
     */
    public static ISWTObservableValue observeText(Control control) {
        if (null !is cast(Label)control) {
            return new LabelObservableValue(cast(Label) control);
        } else if (null !is cast(Link)control) {
            return new LinkObservableValue(cast(Link) control);
        } else if (null !is cast(CLabel)control) {
            return new CLabelObservableValue(cast(CLabel) control);
        } else if (null !is cast(Combo)control) {
            return new ComboObservableValue(cast(Combo) control, SWTProperties.TEXT);
        } else if (null !is cast(CCombo)control) {
            return new CComboObservableValue(cast(CCombo) control,
                    SWTProperties.TEXT);
        } else if (null !is cast(Shell)control) {
            return new ShellObservableValue(cast(Shell) control);
        }

        throw new IllegalArgumentException(
                "Widget [" ~ Class.fromObject(control).getName() ~ "] is not supported."); //$NON-NLS-1$//$NON-NLS-2$
    }

    /**
     * Returns an observable observing the items attribute of the provided
     * <code>control</code>. The supported types are:
     * <ul>
     * <li>org.eclipse.swt.widgets.Combo</li>
     * <li>org.eclipse.swt.custom.CCombo</li>
     * <li>org.eclipse.swt.widgets.List</li>
     * </ul>
     * 
     * @param control
     * @return observable list
     * @throws IllegalArgumentException
     *             if <code>control</code> type is unsupported
     */
    public static IObservableList observeItems(Control control) {
        if (null !is cast(Combo)control) {
            return new ComboObservableList(cast(Combo) control);
        } else if (null !is cast(CCombo)control) {
            return new CComboObservableList(cast(CCombo) control);
        } else if (null !is cast(List)control) {
            return new ListObservableList(cast(List) control);
        }

        throw new IllegalArgumentException(
                "Widget [" ~ Class.fromObject(control).getName() ~ "] is not supported."); //$NON-NLS-1$//$NON-NLS-2$
    }

    /**
     * Returns an observable observing the single selection index attribute of
     * the provided <code>control</code>. The supported types are:
     * <ul>
     * <li>org.eclipse.swt.widgets.Table</li>
     * <li>org.eclipse.swt.widgets.Combo</li>
     * <li>org.eclipse.swt.custom.CCombo</li>
     * <li>org.eclipse.swt.widgets.List</li>
     * </ul>
     * 
     * @param control
     * @return observable value
     * @throws IllegalArgumentException
     *             if <code>control</code> type is unsupported
     */
    public static ISWTObservableValue observeSingleSelectionIndex(
            Control control) {
        if (null !is cast(Table)control) {
            return new TableSingleSelectionObservableValue(cast(Table) control);
        } else if (null !is cast(Combo)control) {
            return new ComboSingleSelectionObservableValue(cast(Combo) control);
        } else if (null !is cast(CCombo)control) {
            return new CComboSingleSelectionObservableValue(cast(CCombo) control);
        } else if (null !is cast(List)control) {
            return new ListSingleSelectionObservableValue(cast(List) control);
        }

        throw new IllegalArgumentException(
                "Widget [" ~ Class.fromObject(control).getName() ~ "] is not supported."); //$NON-NLS-1$//$NON-NLS-2$
    }

    /**
     * @param control
     * @return an observable value tracking the foreground color of the given
     *         control
     */
    public static ISWTObservableValue observeForeground(Control control) {
        return new ControlObservableValue(control, SWTProperties.FOREGROUND);
    }

    /**
     * @param control
     * @return an observable value tracking the background color of the given
     *         control
     */
    public static ISWTObservableValue observeBackground(Control control) {
        return new ControlObservableValue(control, SWTProperties.BACKGROUND);
    }

    /**
     * @param control
     * @return an observable value tracking the font of the given control
     */
    public static ISWTObservableValue observeFont(Control control) {
        return new ControlObservableValue(control, SWTProperties.FONT);
    }
    
    /**
     * Returns an observable observing the editable attribute of
     * the provided <code>control</code>. The supported types are:
     * <ul>
     * <li>org.eclipse.swt.widgets.Text</li>
     * </ul>
     * 
     * @param control
     * @return observable value
     * @throws IllegalArgumentException
     *             if <code>control</code> type is unsupported
     */
    public static ISWTObservableValue observeEditable(Control control) {
        if (null !is cast(Text)control) {
            return new TextEditableObservableValue(cast(Text) control);
        }
        
        throw new IllegalArgumentException(
                "Widget [" ~ Class.fromObject(control).getName() ~ "] is not supported."); //$NON-NLS-1$//$NON-NLS-2$
    }

    private static class DisplayRealm : Realm {
        private Display display;

        /**
         * @param display
         */
        private this(Display display) {
            this.display = display;
        }

        public bool isCurrent() {
            return Display.getCurrent() is display;
        }

        public void asyncExec(Runnable runnable) {
            Runnable safeRunnable = dgRunnable((Runnable runnable_) {
                    safeRun(runnable_);
            }, runnable);
            if (!display.isDisposed()) {
                display.asyncExec(safeRunnable);
            }
        }

        /*
         * (non-Javadoc)
         * 
         * @see java.lang.Object#hashCode()
         */
        public override hash_t toHash() {
            return (display is null) ? 0 : display.toHash();
        }

        /*
         * (non-Javadoc)
         * 
         * @see java.lang.Object#equals(java.lang.Object)
         */
        public override equals_t opEquals(Object obj) {
            if (this is obj)
                return true;
            if (obj is null)
                return false;
            if (Class.fromObject(this) !is Class.fromObject(obj))
                return false;
            final DisplayRealm other = cast(DisplayRealm) obj;
            if (display is null) {
                if (other.display !is null)
                    return false;
            } else if (!display.opEquals(other.display))
                return false;
            return true;
        }
    }
}
